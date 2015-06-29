        .section __TEXT,__text,regular,pure_instructions
        .macosx_version_min 10, 10
        .globl  _main
        .align  4, 0x90
_main:
        # Prologue for _main
        pushq   %rbp
        pushq   %r12
        pushq   %r13
        pushq   %r14
        pushq   %r15
        movq    %rsp, %rbp

        # Allocate 80 bytes of memory on the stack
        subq    $80, %rsp

        # Save the contents of rdi and rsi for later (not sure why though, clang does this for everything it seems)
        movq    %rdi, -8(%rbp)
        movq    %rsi, -16(%rbp)

        # Load a pointer to the file name as the first argument for _fopen
        leaq    L_.file_name(%rip), %rdi

        # Load a pointer to the file flags as the second argument for _fopen
        leaq    L_.file_flags(%rip), %rsi

        # Call _fopen to open the file and get a file pointer
        callq   _fopen

        # Check the result of _fopen, non-0 = success, 0 = failure
        cmp     $0, %rax

        # Jump ahead to file_open_success if _fopen worked
        jne     file_open_success

file_open_failure:
        # Load a pointer to the file open error message as the first argument to _cleanup_after_error
        leaq    L_.file_open_error_message(%rip), %rdi

        # Set 0 as the second argument (file pointer) to _cleanup_after_error
        movq    $0, %rsi

        # Set 0 as the third argument (buffer pointer) to _cleanup_after_error
        movq    $0, %rdx

        # Call _cleanup_after_error to handle _fopen failure
        callq   _cleanup_after_error

        # Set rax to 1 for the program return value
        movq    $1, %rax

        # Jump to the program exit
        jmp     exit

file_open_success:
        # Save the returned file pointer for later
        movq    %rax, -24(%rbp)

        # Set the file pointer as the first argument to _fseeko
        movq    %rax, %rdi

        # Set 0 as the second argument (offset) to _fseeko
        movq    $0, %rsi

        # Set 2 (SEEK_END) as the third argument (whence) to _fseeko
        movq    $2, %rdx

        # Call _fseeko to move to the end of the file
        call    _fseeko

        # Check the result of _fseeko, -1 indicates a failure
        cmp     $-1, %rax

        # Jump ahead to file_seek_success if _fseeko worked
        jne     file_seek_end_success

file_seek_end_failure:
        # Load a pointer to the file seek end error message as the first argument to _cleanup_after_error
        leaq    L_.file_seek_end_error_message(%rip), %rdi

        # Set the file pointer as the second argument to _cleanup_after_error
        movq    -24(%rbp), %rsi

        # Set 0 as the third argument (buffer pointer) to _cleanup_after_error
        movq    $0, %rdx

        # Call _cleanup_after_error to handle _fseeko failure
        callq   _cleanup_after_error

        # Set rax to 1 for the program return value
        movq    $1, %rax

        # Jump to the program exit
        jmp     exit

file_seek_end_success:
        # Set the file pointer as the first argument to _ftello
        movq    -24(%rbp), %rdi

        # Call _ftell to get the current offset (i.e. the size of the file)
        callq   _ftello

        # Check the result of _ftello, -1 indicates a failure
        cmp     $-1, %rax

        # Jump ahead to file_tell_success if _ftello worked
        jne     file_tell_success

file_tell_failure:
        # Load a pointer to the file tell error message as the first argument to _cleanup_after_error
        leaq    L_.file_tell_error_message(%rip), %rdi

        # Set the file pointer as the second argumnet to _cleanup_after_error
        movq    -24(%rbp), %rsi

        # Set 0 as the third argument (buffer pointer) to _cleanup_after_error
        movq    $0, %rdx

        # Call _cleanup_after_error to handle _ftello failure
        callq   _cleanup_after_error

        # Set rax to 1 for the program return value
        movq    $1, %rax

        # Jump to the program exit
        jmp     exit

file_tell_success:
        # Save the file size for later
        movq    %rax, -32(%rbp)

        # Check to see if the file size is less than 4 MB
        cmp     $4194304, %rax

        jb      use_smaller_buffer

use_large_buffer:
        # Use 4 MB as the buffer size
        movq    $4194304, -40(%rbp)

        # Jump over the next statement
        jmp     file_seek_start

use_smaller_buffer:
        # Use the file size as the buffer size
        movq    %rax, -40(%rbp)

file_seek_start:
        # Set the file pointer as the first argument to _fseeko
        movq    -24(%rbp), %rdi

        # Set 0 as the second argument (offset) to _fseeko
        movq    $0, %rsi

        # Set 0 (SEEK_SET) as the third argument (whence) to _fseeko
        movq    $0, %rdx

        # Call _fseeko to move to the start of the file
        call    _fseeko

        # Check the result of _fseeko, -1 indicates a failure
        cmp     $-1, %rax

        # Jump ahead to file_seek_start_success if _fseeko worked
        jne     file_seek_start_success

file_seek_start_failure:
        # Load a pointer to the file seek start error message as the first argument to _cleanup_after_error
        leaq    L_.file_seek_start_error_message(%rip), %rdi

        # Set the file pointer as the second argument to _cleanup_after_error
        movq    -24(%rbp), %rsi

        # Set 0 as the third argument (buffer pointer) to _cleanup_after_error
        movq    $0, %rdx

        # Call _cleanup_after_error to handle _fseeko failure
        callq   _cleanup_after_error

        # Set rax to 1 for the program return value
        movq    $1, %rax

        # Jump to the program exit
        jmp     exit

file_seek_start_success:
        # Set the buffer size as the first argument to _calloc
        movq    -40(%rbp), %rdi

        # Set the size of of each item in the buffer (1 byte) as the second argument to _calloc
        movq    $1, %rsi

        # Call _calloc to allocate zeroed out memory
        callq   _calloc

        # Check the result of _calloc, 0 indicates a failure
        cmp     $0, %rax

        # Jump ahead to file_seek_start_success if _fseeko worked
        jne     buffer_calloc_success

buffer_calloc_failure:
        # Load a pointer to the buffer calloc error message as the first argument to _cleanup_after_error
        leaq    L_.buffer_calloc_error_message(%rip), %rdi

        # Set the file pointer as the second argument to _cleanup_after_error
        movq    -24(%rbp), %rsi

        # Set 0 as the third argument (buffer pointer) to _cleanup_after_error
        movq    $0, %rdx

        # Call _cleanup_after_error to handle _calloc failure
        callq   _cleanup_after_error

        # Set rax to 1 for the program return value
        movq    $1, %rax

        # Jump to the program exit
        jmp     exit

buffer_calloc_success:
        # Save the pointer to the buffer for later
        movq    %rax, -48(%rbp)

        # Set the total number of bytes read to 0
        movq    $0, -56(%rbp)

        # Zero out the counters of each base
        xorq    %r12, %r12
        xorq    %r13, %r13
        xorq    %r14, %r14
        xorq    %r15, %r15

file_read_loop_start:
        # Temporarily move the total number of bytes read into r8 for comparison
        movq    -56(%rbp), %r8

        # Compare the file size to the total number of bytes read
        cmp     -32(%rbp), %r8

        # Jump to the end of the read loop if the total number of bytes read is greater than or equal to the file size
        jae      file_read_loop_end

        # Set the pointer to the buffer as the first argument to _fread
        movq    -48(%rbp), %rdi

        # Set 1 (the item size) as the second argument to _fread
        movq    $1, %rsi

        # Set the buffer size (number of items) as the third argument to _fread
        movq    -40(%rbp), %rdx

        # Set the file pointer as the fourth argument to _fread
        movq    -24(%rbp), %rcx

        # Call _fread to read up to the buffer size number of bytes
        callq   _fread

        # Save the actual number of bytes for later
        movq    %rax, -64(%rbp)

        # Set the file pointer as the first argument to _ferror
        movq    -24(%rbp), %rdi

        # Call _ferror to check to see if the error indicator is set
        callq   _ferror

        # Check the result of _ferror, 0 = no error, non-0 = error
        cmp     $0, %rax

        # Jump ahead if _fread worked
        je     file_read_success

file_read_failure:
        # Load a pointer to the file read error message as the first argument to _cleanup_after_error
        leaq    L_.file_read_error_message(%rip), %rdi

        # Set the file pointer as the second argument to _cleanup_after_error
        movq    -24(%rbp), %rsi

        # Set the buffer pointer as the third argument to _cleanup_after_error
        movq    -48(%rbp), %rdx

        # Call _cleanup_after_error to handle _calloc failure
        callq   _cleanup_after_error

        # Set rax to 1 for the program return value
        movq    $1, %rax

        # Jump to the program exit
        jmp     exit

file_read_success:
        # Temporarily move the actual number of bytes read into r8 for add
        movq    -64(%rbp), %r8

        # Add the actual number of bytes read to the total number of bytes read
        addq    %r8, -56(%rbp)

        # Set the current offset in the buffer to 0
        movq    $0, -72(%rbp)

base_check_loop_start:
        # Temporarily move the current offset in the buffer into r8 for comparison
        movq    -72(%rbp), %r8

        # Compare the actual number of bytes read to the current offset in the buffer
        cmp     -64(%rbp), %r8

        # Jump to the end of the print loop if the current offset in the buffer is greater than or equal to the actual number of bytes read
        jae      base_check_loop_end

        # Move the current offset in the buffer into rax for movsbl
        movq    -72(%rbp), %rax

        # Move the pointer to the buffer into rcx for movsbl
        movq    -48(%rbp), %rcx

        movsbl  (%rcx, %rax), %eax

        cmpl    $83, %eax
        jg      check_for_base_t

check_for_base_a:
        cmpl    $65, %eax
        je      base_a

check_for_base_c:
        cmpl	$67, %eax
        jne	check_for_base_g

base_c:
        addq    $1, %r13
        jmp     done_checking_base

check_for_base_t:
        cmpl    $84, %eax
        jne     done_checking_base

base_t:
        addq     $1, %r15
        jmp     done_checking_base

base_a:
        addq    $1, %r12
        jmp     done_checking_base

check_for_base_g:
        cmpl    $71, %eax
        jne     done_checking_base

base_g:
        addq $1, %r14

done_checking_base:
        # Incriment the current offset in the buffer by 1
        addq    $1, -72(%rbp)

        # Jump back up to the start of the base check loop
        jmp     base_check_loop_start

base_check_loop_end:
        # Jump back up to the start of the fread loop
        jmp     file_read_loop_start

file_read_loop_end:
        # Set the file pointer as the first argument to _fclose
        movq    -24(%rbp), %rdi

        # Call _fclose to close the file
        callq   _fclose

        # Set the pointer to the buffer as the first argument to _free
        movq    -48(%rbp), %rdi

        # Call _free to free the buffer
        callq   _free

        leaq    L_.base_output(%rip), %rdi
        movq    %r12, %rsi
        movq    %r13, %rdx
        movq    %r14, %rcx
        movq    %r15, %r8
        movb    $0, %al
        callq   _printf

        # Set eax to 0 for the program return value
        xorl    %eax, %eax

exit:
        # Restore the contents of rdi and rsi
        movq    -8(%rbp), %rdi
        movq    -16(%rbp), %rsi

        # Reclaim the 80 bytes allocated on the stack
        addq    $80, %rsp

        # Epilogue for _main
        popq    %r15
        popq    %r14
        popq    %r13
        popq    %r12
        popq    %rbp
        retq

# rdi = error mesage
# rsi = file pointer
# rdx = buffer pointer
	.globl	_cleanup_after_error
	.align	4, 0x90
_cleanup_after_error:
        # _handle_errors prologue
        pushq   %rbp
        movq	%rsp, %rbp

        # Allocate 32 bytes on the stack
        subq    $32, %rsp

        # Save the error message string pointer for later
        movq    %rdi, -8(%rbp)

        # Save the file pointer for later
        movq    %rsi, -16(%rbp)

        # Save the buffer pointer for later
        movq    %rdx, -24(%rbp)

        leaq    L_.debug_string(%rip), %rdi
        movq    -8(%rbp), %rsi
        movb    $0, %al
        callq   _printf

        leaq    L_.debug_value(%rip), %rdi
        movq    -16(%rbp), %rsi
        movb    $0, %al
        callq   _printf

        leaq    L_.debug_value(%rip), %rdi
        movq    -24(%rbp), %rsi
        movb    $0, %al
        callq   _printf

        # Check to see if a pointer to an error message string was passed
        cmpq    $0, -8(%rbp)

        # Jump ahead if not
        je      skip_printing_error_message

        # Call ___error to get errno
        callq   ___error

        # Set errno as the first argument to _strerror
        movq    (%rax), %rdi

        # Call _strerror to get a pointer to a string represention of errno
        callq   _strerror

        # Set a pointer to stderr as the first argument to _fprintf
        movq    ___stderrp@GOTPCREL(%rip), %r8
        movq    (%r8), %rdi

        # Set the pointer to the error message string as the second argument to _fprintf
        movq    -8(%rbp), %rsi

        # Set the pointer returned by _strerror as the third argument to _fprintf
        movq    %rax, %rdx

        # No floating point arguments were passed so set al to 0
        movb    $0, %al

        # Call _fprintf to print the error to stderr
        callq   _fprintf

skip_printing_error_message:
        # Check to see if a file pointer was passed
        cmpq    $0, -16(%rbp)

        # Jump ahead if not
        je      skip_close_file

        # Set the file pointer as the first argument to _fclose
        movq    -16(%rbp), %rdi

        # Call _fclose to close the file
        callq   _fclose

skip_close_file:
        # Check to see if a pointer to a buffer was passed
        cmpq    $0, -24(%rbp)

        # Jump ahead if not
        je      skip_free_buffer

        # Set the pointer to a buffer as the first argument to _free
        movq    -24(%rbp), %rdi

        # Call _free to free the buffer
        callq   _free

skip_free_buffer:
        addq    $32, %rsp

        popq    %rbp

        retq

.section __TEXT,__cstring,cstring_literals
L_.file_name:
        .asciz  "data/001.txt"

L_.file_flags:
        .asciz  "rb"

L_.file_open_error_message:
        .asciz  "Could not open file: %s\n"

L_.file_seek_end_error_message:
        .asciz  "Could not seek to end of file: %s\n"

L_.file_tell_error_message:
        .asciz  "Could not tell the file offset: %s\n"

L_.file_seek_start_error_message:
        .asciz  "Could not seek to start of file: %s\n"

L_.buffer_calloc_error_message:
        .asciz  "Could not allocate memory for buffer: %s\n"

L_.file_read_error_message:
        .asciz  "Could not read from file: %s\n"

L_.base_output:
        .asciz  "%llu %llu %llu %llu\n"

L_.single_character:
        .asciz  "%c"

L_.debug_value:
        .asciz  "DEBUG VALUE: %d\n"

L_.debug_string:
        .asciz  "DEBUG STRING: %s\n"

.subsections_via_symbols
