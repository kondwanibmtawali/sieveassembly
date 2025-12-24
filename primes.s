/* Kondwani Mtawali 
Primes Assembler 
 */
        .section .data
primes: .space 1250 #Declaration of primes array(1250 bytes = 10,000 bits)
sprompt: .asciz "The program finds all the prime numbers up to a 10,000 and prints out the first 200 of those primes. \n"
twohunprint: .asciz "All numbers are initially set as prime. Numbers 0 - 199 are printed below: \n"
allnumsprint: .asciz "All prime numbers up until 10,000 are to be printed below: \n"
numprimes: .asciz "Total number of primes found: %d \n"
usernum: .long 0
newline: .asciz "\n"
formatted_string: .asciz " %d |" # Format for printing primes
        .section .bss
        .section .text
        .globl main
        .type main, @function
        main: 
        
        #Printing prompts
         leaq sprompt(%rip), %rdi      # Put address of prompt in %rdi register for printf
         xorq %rax, %rax               # Zero %rax for end of parameters for printf
         call printf                   # Prints prompt
                
        #Initializing all bits to 1
        leaq primes(%rip), %r12               #Loads primes array into r12
        clrq %rcx                       #Acts as index value that's incremented
        init_loop:        
                cmp $1250, %rcx         #Comparison that checks that we've reached 10,000 bits(1250 bytes)          
                je continue            #If the counter equals 10,000 bits we continue the program
                movb $0xFF, (%r12, %rcx, 1)  #Sets each byte to 0xFF(1111 1111)
                incq %rcx               #Increments the counter
                jmp init_loop

        continue:

        #Printing numbers 1 - 200[All numbers initialized to 1, all numbers appear as prime]
         leaq twohunprint(%rip), %rdi      # Put address of prompt in %rdi register for printf
         xorq %rax, %rax               # Zero %rax for end of parameters for printf
         call printf                   # Prints prompt

         xorq %rax, %rax         #Clears rax
         
         call printPrimes        #Prints numbers 1 through 200 as initially all are marked as prime

         movq $newline, %rdi     #Loads the address of the new line into rdi
         xorq %rax, %rax         #Clears rax to call printf
         call printf

        #Printing all numbers up to 10000
         leaq allnumsprint(%rip), %rdi      # Put address of prompt in %rdi register for printf
         xorq %rax, %rax               # Zero %rax for end of parameters for printf
         call printf                   # Prints prompt

         movq $0, %rdi             #Moves 0 into rdi to mark it as non prime
         call markNonPrime

         movq $1, %rdi
         call markNonPrime

         call multsTwo

         call markMultiplesOfOddNumbers

         call printPrimes

         #Finds all the primes 
         movq $0, %r14          #Initializes prime counter to 0
         movq $0, %rdi           #Starts at 0
         totalNumofPrimes:
                cmpq $10000, %rdi
                jge printTotal

                call findPrime          #Calls findPrime to determine if number is prime
                incq %rdi 
                cmpq $1, %rax           #Checks if number is prime
                jne totalNumofPrimes    #If the number isn't prime jump back to start of loop
                incq %r14               #Else if the number is prime increment the prime counter

                jmp totalNumofPrimes
        printTotal:
                movq %r14, %rsi
                movq $numprimes, %rdi   # Address of format string in %rdi (1st argument to printf)
                xorq %rax, %rax                # Clear %rax to indicate end of variable arguments
                call printf                    # Call printf to print "| %d |"

exit: 
    movq $60, %rax             # System call number for exit
    xorq %rdi, %rdi            # Exit code 0
    syscall

printPrimes:
        xorq %r13, %r13         #%r13 contains the number of primes printed
        xorq %rbp, %rbp         #Number we are checking to be prime or not to determine if it will be printed

        next_number:
                cmpq $10000, %rbp     #Compares the current value with the max value
                jge done            #If we're outside the limit, exit

                cmp $200, %r13       #Compare prime counter with 200
                jge done            #If we have printed 200 primes, exit

                movq %rbp, %rdi              #Load current number into %rdi
                push %rbp
                push %rdi
                call findPrime     #Call findPrime to check if %rdi is prime
                pop %rbp
                pop %rdi
                incq %rbp              #Increments rbp to go to next number

                cmpq $1, %rax         #Compare result of findPrime with 1 (prime)
                jne next_number      #If result is not 1, check next number

                call print_prime     #Call print_prime to print the number

                # Use division to check the remainder (%r13 % 10) against 0.
                xorq %rax, %rax         #Clearing rax for modular division
                xorq %rdx, %rdx         #clears rdx

                mov %r13, %rax          #moves the the number of printed primes(dividend) into rax
                mov $10, %rbx           #moves the divisor(10) into rbx
                idivq %rbx              #Performs modular division. Rax contains quotient, rdx contains remainder

                cmp $0, %rdx            #Compares the remainder to zero
                jne next_number       #If remainder insn't zero then we continue printing the line

                call print_newline      #if it is zero we print a new line
                jmp next_number

        #Function to print a single prime number in the required format
         print_prime:
                movq %rdi, %rsi              # Copy the number to %rsi for printing
                push %rsi
                push %rdi
                call print_formatted         # Call a function that handles formatted printing
                pop %rsi
                pop %rdi
                incq %r13
                ret

        #Function to print a newline after 10 primes
         print_newline:
                xorq %rdi, %rdi
                movq $newline, %rdi     #Loads the address of the new line into rdi
                xorq %rax, %rax         #Clears rax to call printf
                call printf
                ret

        #Formatting function
         print_formatted:
                xorq %rdi, %rdi
                movq $formatted_string, %rdi   # Address of format string in %rdi (1st argument to printf)
                xorq %rax, %rax                # Clear %rax to indicate end of variable arguments
                call printf                    # Call printf to print "| %d |"
                ret       

         done:
                ret         
                 

findPrime:
        #Calculating the location of the bit
        movq %rdi, %rax         #Loads dividend into rax
        xorq %rdx, %rdx         #Clears rdx
        movq $64, %rbx          #Moves divisor into rbx
        idivq %rbx              #Register rax contains the quotient(line number), rdx contains the remainder(bit position)

        shl $3, %rax            #Multiplyes the byte number in rax by 8 to find the line number. shl $3 is the same as multiplying by 8
        mov %rdx, %rbx          #Loads the bit position into rbx
        shr $3, %rbx            #Divide 8 to get the byte offset
        add %rbx, %rax          #Adds the bit position to the line number to find desired bit. 
        
        movb primes(,%rax,1), %bl         #Loads the byte containing the specifc bit into bl
        mov %rdx, %rcx          #Moves the bit position into rcx
        and $7, %rcx            #Isolates the exact bit position within the byte which will range from 0 to 7
        mov $1, %rdx            #Moves the 1(binary notation) into rdx
        shl %rcx, %rdx          #Shifts the 1 in rdx left by the number of positions specified in rcx to create MASK(rdx)

        test %bl, %dl           #Performs bitwise AND operation without changing the registers
        jnz isPrime             #If test relult isn't zero the number is prime
        jz notPrime             #if the result is zero, the number isn't prime

        isPrime: 
                mov $1, %rax    #sets rax to 1
                ret
        notPrime:
                mov $0, %rax    #sets rax to 0
                ret

markNonPrime:
        movq %rdi, %rax          # Load bit position (in %rdi) into %rax
        shr $3, %rax             # Divide bit position by 8 to get the byte offset
        movb primes(,%rax,1), %bl # Set the byte at the offset to 0 (mark as non-prime)

        movq %rdi, %rcx          #Moves bit position into rcx
        andq $7, %rcx            #Isolates the bit position within the byte
        movq $1, %rdx            #Load 1 into %rdx
        shl %cl, %rdx            #Shifts 1 left by the position to create the mask

        notq %rdx               #Inverts the bits of the mask so 0 is at the target bit
        andb %dl, %bl           #Clears the target bit in %bl

        movb %bl, primes(,%rax,1)       #Store the updated byte back into the primes array


        ret

multsTwo:
        movq $4, %rdi             # Start with 2 (the first prime)
    
        nextMultipleOfTwo:
                cmpq $10000, %rdi      # Check if we've reached 10,000
                jge doneMultiplesOfTwo # If we have reached 10,000, exit the loop

                # Skip marking 2 itself
                #cmpq $2, %rdi
                #je skipTwo
                call markNonPrime

                addq $2, %rdi          # Increment to the next multiple of 2
                jmp nextMultipleOfTwo   # Repeat for the next multiple of 2

        doneMultiplesOfTwo:
                ret


markMultiplesOfOddNumbers:
        movq $3, %rdi             # Start with 3 (first odd prime)
    
        nextOdd:
                cmpq $10000, %rdi      # Check if we've reached 10,000
                jge doneMultiplesOfOdd # If we've reached 10,000 exit the loop

                call findPrime          #Checks if the current number we're checking is prime or not
                cmpq $1, %rax           #If the number isn't marked prime we skip marking it
                jne skipPrime

                # Mark multiples of the odd prime number as non-prime
                movq %rdi, %rcx        # Load current odd number into rcx

                addq %rdi, %rcx
                #movq %rdi, %rcx         #moves rdi into rcx     
                #imulq %rdi, %rcx        #Multiples the current number by itself and stores it into rcx

                nextMultiple:
                        cmpq $10000, %rcx   # Check if it's within range
                        jge skipPrime     # Exit if the multiple exceeds 10,000

                        movq %rdi, %r8
                        movq %rcx, %rdi         #Moves the current multiple into rdi to be marked non prime
                        push %rdi
                        push %rcx
                        call markNonPrime    # Mark this multiple as non-prime
                        pop %rcx
                        pop %rdi
                        movq %r8, %rdi
                        addq %rdi, %rcx            # Move to the next multiple of the current odd number
                        jmp nextMultiple     # Repeat for the next multiple

                        skipPrime:
                                cmpq $10000, %rdi   # Check if it's within range
                                jge doneMultiplesOfOdd # Exit if the multiple exceeds 10,000

                                addq $2, %rdi          # Increment to the next odd number
                                jmp nextOdd             # Repeat for the next odd number

                        doneMultiplesOfOdd:
                                ret


