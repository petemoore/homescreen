.global uart_init
.global uart_send
.global uart_hex
.global uart_puts
.global wait_cycles
# ------------------------------------------------------------------------------
# Initialise the Mini UART interface for logging over serial port.
# Note, this is Broadcomm's own UART, not the ARM licenced UART interface.
# ------------------------------------------------------------------------------
uart_init:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x1, #0x5004
  movk    x1, #0x3f21, lsl #16            // x1 = 0x3f215004 = AUX_ENABLES (Auxiliary enables)
  ldr     w2, [x1]
  orr     w2, w2, #1
  str     w2, [x1]                        //   [AUX_ENABLES] |= 0x00000001 => Enable Mini UART.
  movk    x1, #0x5044                     // x1 = 0x3f215044 = AUX_MU_IER_REG (Mini UART Interrupt Enable)
  str     wzr, [x1]                       //   [AUX_MU_IER_REG] = 0x00000000 => Disable interrupts.
  movk    x1, #0x5060                     // x1 = 0x3f215060 = AUX_MU_CNTL_REG (Mini UART Extra Control)
  str     wzr, [x1]                       //   [AUX_MU_CNTL_REG] = 0x00000000 => Disable Mini UART Tx/Rx
  mov     w2, #0x6                        // w2 = 6
  movk    x1, #0x5048                     // x1 = 0x3f215048 = AUX_MU_IIR_REG (Mini UART Interrupt Identify)
  str     w2, [x1]                        //   [AUX_MU_IIR_REG] = 0x00000006 => Mini UART clear Tx, Rx FIFOs
  mov     w3, #0x3                        // w3 = 3
  movk    x1, #0x504c                     // x1 = 0x3f21504c = AUX_MU_LCR_REG (Mini UART Line Control)
  str     w3, [x1]                        //   [AUX_MU_LCR_REG] = 0x00000003 => Mini UART in 8-bit mode.
  movk    x1, #0x5050                     // x1 = 0x3f215050 = AUX_MU_MCR_REG (Mini UART Modem Control)
  str     wzr, [x1]                       //   [AUX_MU_MCR_REG] = 0x00000000 => Set UART1_RTS line high.
  mov     w2, #0x10e                      // w2 = 270
  movk    x1, #0x5068                     // x1 = 0x3f215068 = AUX_MU_BAUD_REG (Mini UART Baudrate)
  str     w2, [x1]                        //   [AUX_MU_BAUD_REG] = 0x0000010e => baudrate = system_clock_freq/(8*(270+1))
  mov     x1, #0x4
  movk    x1, #0x3f20, lsl #16            // x1 = 0x3f200004 = GPFSEL1 (GPIO Function Select 1)
  ldr     w2, [x1]                        // w2 = [GPFSEL1]
  and     w2, w2, #0xfffc0fff             // Unset bits 12, 13, 14 (FSEL14 => GPIO Pin 14 is an input).
                                          // Unset bits 15, 16, 17 (FSEL15 => GPIO Pin 15 is an input).
  orr     w2, w2, #0x00002000             // Set bit 13 (FSEL14 => GPIO Pin 14 takes alternate function 5).
  orr     w2, w2, #0x00010000             // Set bit 16 (FSEL15 => GPIO Pin 15 takes alternative function 5).
  str     w2, [x1]                        //   [GPFSEL1] = updated value => Enable UART 1.
  movk    x1, #0x94                       // x1 = 0x3f200094 = GPPUD (GPIO Pin Pull-up/down Enable)
  str     wzr, [x1]                       //   [GPPUD] = 0x00000000 => GPIO Pull up/down = OFF
  mov     x0, #0x96                       // x0 = 150
  bl      wait_cycles                     // Wait 150 instruction cycles.
  mov     w2, #0xc000                     // w2 = 2^14 + 2^15
  movk    x1, #0x98                       // x1 = 0x3f200098 = GPPUDCLK0 (GPIO Pin Pull-up/down Enable Clock 0)
  str     w2, [x1]                        //   [GPPUDCLK0] = 0x0000c000 => Control signal to lines 14, 15.
  mov     x0, #0x96                       // x0 = 150
  bl      wait_cycles                     // Wait 150 instruction cycles.
  str     wzr, [x1]                       //   [GPPUDCLK0] = 0x00000000 => Remove control signal to lines 14, 15.
  mov     x1, #0x5060
  movk    x1, #0x3f21, lsl #16            // x1 = 0x3f215060 = AUX_MU_CNTL_REG (Mini UART Extra Control)
  str     w3, [x1]                        //   [AUX_MU_CNTL_REG] = 0x00000003 => Enable Mini UART Tx/Rx
  ldp     x29, x30, [sp], #16             // Restore frame pointer, link register.
  ret                                     // Return.

# ------------------------------------------------------------------------------
# Wait (at least) x0 instruction cycles.
# ------------------------------------------------------------------------------
wait_cycles:
  subs    x0, x0, #0x1                    // x0 -= 1
  b.ne    wait_cycles                           // Repeat until x0 == 0.
  ret                                     // Return.


uart_send:
	mov	x2, 20564
	movk	x2, 0x3f21, lsl 16
	.p2align 3
.L8:
	// Start of user assembly
// 75 "uart.c" 1
	nop
// 0 "" 2
	// End of user assembly
	ldr	w1, [x2]
	tbz	x1, 5, .L8
	mov	x1, 20544
	movk	x1, 0x3f21, lsl 16
	str	w0, [x1]
	ret
	.size	uart_send, .-uart_send
	.align	2
	.p2align 4,,15
	.global	uart_getc
	.type	uart_getc, %function
uart_getc:
	mov	x1, 20564
	movk	x1, 0x3f21, lsl 16
	.p2align 3
.L12:
	// Start of user assembly
// 86 "uart.c" 1
	nop
// 0 "" 2
	// End of user assembly
	ldr	w0, [x1]
	tbz	x0, 0, .L12
	mov	x0, 20544
	movk	x0, 0x3f21, lsl 16
	mov	w1, 10
	ldr	w0, [x0]
	and	w0, w0, 255
	cmp	w0, 13
	csel	w0, w0, w1, ne
	ret
	.size	uart_getc, .-uart_getc
	.align	2
	.p2align 4,,15
	.global	uart_puts
	.type	uart_puts, %function
uart_puts:
	ldrb	w1, [x0]
	cbz	w1, .L16
	mov	x2, 20564
	movk	x2, 0x3f21, lsl 16
	mov	x4, 20544
	movk	x4, 0x3f21, lsl 16
	mov	w5, 13
	.p2align 3
.L21:
	cmp	w1, 10
	beq	.L19
.L18:
	ldrb	w3, [x0], 1
	.p2align 3
.L20:
	// Start of user assembly
// 75 "uart.c" 1
	nop
// 0 "" 2
	// End of user assembly
	ldr	w1, [x2]
	tbz	x1, 5, .L20
	str	w3, [x4]
	ldrb	w1, [x0]
	cbnz	w1, .L21
.L16:
	ret
	.p2align 3
.L19:
	// Start of user assembly
// 75 "uart.c" 1
	nop
// 0 "" 2
	// End of user assembly
	ldr	w1, [x2]
	tbz	x1, 5, .L19
	str	w5, [x4]
	b	.L18
	.size	uart_puts, .-uart_puts
	.ident	"GCC: (GNU) 7.2.0"
