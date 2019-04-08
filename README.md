# JITCrashTester
A reproduction of a crash in the JavaScriptCore Macro Assembler as used in Qt 5.12.2.

The crash in question takes the form of a segfault on attempting to execute code in memory not marked executable. I believe it is caused by a bug in the syntax of inheritance and member functions of the branch compacting link buffer. An example of how this crash can arise is as follows:

1. JIT a function that takes 1.5 pages of memory. It will allocate two pages and leave the second half of the second page free.
2. JIT a function that takes 0.1 pages of memory. It will be put into the empty second half of the second page.
3. Release the first function.
4. JIT a function that takes 1.1 pages of memory. It will be put into the empty area freed by the first function. On ARM, suppose this is then compacted to 0.9 pages of memory (all functions on ARM are compacted).

The bug occurs at this point. First, `BranchCompactingLinkBuffer<MacroAssembler>::linkCode(...)`, it will make both pages writable initially due to the line
  
`ExecutableAllocator::makeWritable(m_code, m_initialSize);`
  
Then, later, it will call `LinkBufferBase<MacroAssembler, ExecutableOffsetCalculator>::performFinalization()`, which will make just the first page executable with the line
  
`ExecutableAllocator::makeExecutable(code(), static_cast<int>(m_size));`
  
What it *should* do is call `BranchCompactingLinkBuffer<MacroAssembler>::performFinalization()`, which has the line
  
`ExecutableAllocator::makeExecutable(code(), m_initialSize);`
  
(the critical difference being `m_initialSize`). There is even a comment to the effect that this is the version of `performFinalization()` that we should expect to see called. However, it is not what is being called, because when the function is called from the base class, the base class version of the function is called rather than the derived class version.

5. Call the 0.1-page function. It resides in memory that will no longer be marked executable, and you will get a segfault.
