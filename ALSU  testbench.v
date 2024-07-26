module test_ALU_TB ();

localparam WIDTH_TB = 4 ;
localparam INPUT_PRIORITY_TB = "A" ; // the code is designed for A if we make it B we need to update this part in testbech
localparam FULL_ADDER_TB = "ON" ;  // the code is designed for ON if we make it OFF we need to update this part in testbech

reg [WIDTH_TB-1 : 0 ] A_TB ,B_TB ;
reg Cin_TB ;  
reg red_op_A_TB ,red_op_B_TB ; 
reg [2 : 0 ] Opcode_TB ;
reg bypass_B_TB ,bypass_A_TB ; 

wire [2*WIDTH_TB-1 : 0] out_TB ;
reg [2*WIDTH_TB-1 : 0] out_Expected ;

wire Odd_parity_TB ; 
reg Odd_parity_EXpected ; 

wire Invalid_TB;  
reg Invalid_Expected;  


test_ALU  #(.INPUT_PRIORITY (INPUT_PRIORITY_TB) , .FULL_ADDER(FULL_ADDER_TB) ,  .WIDTH(WIDTH_TB)  ) 
																		
																		DUT (.A(A_TB) , .B(B_TB) , .out(out_TB)  , .Cin(Cin_TB) , 

																		.red_op_A(red_op_A_TB) , .red_op_B(red_op_B_TB) , .Opcode(Opcode_TB) ,

																		.bypass_B(bypass_B_TB) , .bypass_A(bypass_A_TB)  , 

																		.Odd_parity(Odd_parity_TB) , .Invalid(Invalid_TB)   ) ;



		integer i ;

	initial

begin


A_TB = 4'b1111 ; B_TB = 4'b0000 ; Opcode_TB = 3'b101 ; Invalid_Expected = 1 ;  #10 ;

	if(Invalid_TB != Invalid_Expected )
	begin
		$display("The invalid signal doesn't work properly at division by ZERO");
		$stop ;
	end	
		Opcode_TB = 3'b110 ; #10;
		if(Invalid_TB != Invalid_Expected )
		begin
			$display("The invalid signal doesn't work properly at op code = 110");
			$stop;
		end
			Opcode_TB = 3'b111 ; #10;
			if(Invalid_TB != Invalid_Expected ) 
			begin
				$display("The invalid signal doesn't work properly at op code = 111");
				$stop;
			end

			Opcode_TB = 3'b010 ; /*to be updated correctly*/
		for(i = 0  ; i < 5 ; i = i+1)
			begin		
					bypass_A_TB = 0 ; /*to go to else condition*/
					bypass_B_TB = 0 ;
					red_op_A_TB = $random ;
					red_op_B_TB = $random ;
					Invalid_Expected = red_op_A_TB || red_op_B_TB ;

					#10;

					if( (Invalid_TB != Invalid_Expected)  && (red_op_A_TB || red_op_B_TB) )
						begin
							$display("The invalid signal doesn't work properly for operations rather than AND , XOR");
							$display("The Opcode     = %b" , Opcode_TB);
							$display("The red_op_A   = %b" , red_op_A_TB);
							$display("The red_op_B   = %b" , red_op_B_TB);
							$display("The Invalid_TB = %b" , Invalid_TB);
							$display("The Invalid_Expected = %b" , Invalid_Expected);
							$stop;
						end	
					Opcode_TB = Opcode_TB + 1 ;
					#10;
			end

Invalid_Expected = 0;

		for (i=0 ; i <= 100 ; i=i+1)
			begin
				A_TB = $urandom_range(0,15) ;
				B_TB =  $urandom_range(0,15); 
				Opcode_TB = $urandom_range(0,7) ;
				Cin_TB = $random ;
				red_op_A_TB = $random;
				red_op_B_TB = $random ;
				bypass_B_TB = $random ;
				bypass_A_TB = $random ;
 
					if(bypass_A_TB)
						out_Expected = A_TB ; 

					else if(bypass_B_TB && !bypass_A_TB)
							out_Expected = B_TB ; 

					else
							begin

								out_Expected = 0 ; 
								Odd_parity_EXpected = 0 ;
								Invalid_Expected = 0 ;

									if(Opcode_TB == 3'b000 )
										begin
												if(red_op_A_TB && red_op_B_TB)
													begin
														Invalid_Expected = 1 ;
														out_Expected = & A_TB ; 			
													end
												else if (red_op_A_TB)
												 out_Expected = & A_TB ;
												else if (red_op_B_TB) 
												out_Expected = & B_TB ;
												else out_Expected = A_TB & B_TB ;

										end

									else if(Opcode_TB == 3'b001 )
										begin
											if(red_op_A_TB && red_op_B_TB)
												begin
													Invalid_Expected = 1 ;
													out_Expected = ^ A_TB ; 			
												end

											else if (red_op_A_TB) out_Expected = ^A_TB ;
											else if (red_op_B_TB) out_Expected = ^B_TB ;
											else out_Expected = A_TB ^ B_TB ;

										end 

											else if (Opcode_TB == 3'b010)
												begin
													if(red_op_A_TB || red_op_B_TB)
													Invalid_Expected = 1 ;
													else  
													Invalid_Expected = 0 ;
													out_Expected = A_TB + B_TB + Cin_TB ;
													Odd_parity_EXpected = ~^out_Expected ;					 			
												end 

											else if (Opcode_TB == 3'b011)
												begin
													if(red_op_A_TB || red_op_B_TB)
													Invalid_Expected = 1 ;
													else  
													Invalid_Expected = 0 ;
													out_Expected = A_TB * B_TB   ;
													Odd_parity_EXpected = ~^out_Expected ;
												end	

												else if (Opcode_TB == 3'b100)
												begin
													if(red_op_A_TB || red_op_B_TB)
														Invalid_Expected = 1 ;
													else  
														Invalid_Expected = 0 ;

														if (A_TB >= B_TB)
														out_Expected = A_TB - B_TB   ;
														else
														out_Expected = B_TB - A_TB ;
													Odd_parity_EXpected = ~^out_Expected ;
												end	
	
												else if (Opcode_TB == 3'b101)

													begin
														if(red_op_A_TB || red_op_B_TB)
															Invalid_Expected = 1 ;
															else 
															Invalid_Expected = 0 ;
															
															if (!A_TB && !B_TB)
															out_Expected = {2*WIDTH_TB {1'b0}} ; // Corrected from `out` to `out_Expected`

															else if(B_TB == 0)
																begin
																	out_Expected = -1;
																	Invalid_Expected = 1 ;	
																end

															else
															out_Expected = A_TB / B_TB ;

														Odd_parity_EXpected = ~^out_Expected;
													end
												else 
												
													begin
														Invalid_Expected = 1 ;
														out_Expected = 0 ;		
													end	


				#10 ;
				if(out_TB != out_Expected || Odd_parity_TB != Odd_parity_EXpected || Invalid_TB != Invalid_Expected)
					begin
						$display("Error at time = %t" , $time);
						$display("A = %b // B = %b // Opcode = %b " , A_TB , B_TB , Opcode_TB);
						$display("testbench output = %b // EXpected output = %b " ,  out_TB ,out_Expected );
						$display("Odd_parity_TB = %b // Odd_parity_EXpected = %b " , Odd_parity_TB , Odd_parity_EXpected );
						$display("Invalid_TB = %b // Invalid_Expected = %b " , Invalid_TB , Invalid_Expected );
						$stop ; 

					end

			end

			end

					 	
	$display("The testbench is successfully done" );			 	
	$stop ; 
	end 


endmodule
