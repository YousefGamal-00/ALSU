module test_ALU (A ,B ,Cin ,red_op_A ,red_op_B ,Opcode ,bypass_A ,bypass_B ,out ,Odd_parity ,Invalid );

parameter INPUT_PRIORITY  = "A";
parameter FULL_ADDER  = "ON";  
parameter  WIDTH = 4 ;

input [WIDTH-1 : 0 ] A ,B ;
input Cin ; // used when FULL ADDER is "ON"
input red_op_A ,red_op_B ; 
//when the op code is (&) | (^) check if it is high then make the operation
input [2 : 0 ] Opcode ;
input bypass_B ,bypass_A ; 
//when it is High pass one from A or B to output independent on opcode

output reg [2*WIDTH-1 : 0] out ; // including carry out

output reg Odd_parity ; 
/*default is zero and changed if we in Arithmetic operation only (XNOR) */ 

output reg Invalid;  

/*when invalid opcode is executed */

always @(*) 
begin
		out = 0 ;
		Odd_parity = 0 ;
		Invalid = 0 ;

		if(bypass_A && bypass_B)
			begin
			 	if (INPUT_PRIORITY == "A")
			 		out = A ;
			 	else
			 		out = B ;
			 end 

		else if(bypass_A)
			 	out = A ;

		else if(bypass_B)
		out = B ;	 	

		else
			begin	
					case(Opcode)
				3'b000 : 

						begin
								if(red_op_A && red_op_B)
									begin
										Invalid = 1 ;
										if (INPUT_PRIORITY == "A")
									 		out = &A ;
									 	else
									 		out = &B ;		
									end

								else if (red_op_A)
											out = &A ;

								else if (red_op_B)
											out = &B ;

								else out = A & B ;						 		
						end	

				3'b001 :

					 	begin
								if(red_op_A && red_op_B)
									begin
										Invalid = 1 ;
										if (INPUT_PRIORITY == "A")
									 		out = ^A ;
									 	else
									 		out = ^B ;		
									end

								else if (red_op_A)
											out = ^A ;

								else if (red_op_B)
											out = ^B ;
											
								else out = A ^ B ;						 		
						end	
				3'b010 : 
						begin
							
							if(red_op_A || red_op_B)
							Invalid = 1 ;
							else 
							Invalid = 0 ;

								if(FULL_ADDER == "ON")
									begin
										out = A + B + Cin ;
										Odd_parity = ~^out ;					 			
									end	
								else
									 begin
											out = A + B ;
											Odd_parity = ~^out ;				 			
									 end					 		
						end	

				3'b011 : 
						begin

							if(red_op_A || red_op_B)
								Invalid = 1 ;
								else 
								Invalid = 0 ;

								out = A * B ;	
								Odd_parity = ~^out ;
						end	

				3'b100 :
					begin
							if(red_op_A || red_op_B)
							Invalid = 1 ;
							else 
							Invalid = 0 ;

					 		if (A>=B)
					 			begin
					 				out = A - B ;
					 				Odd_parity = ~^out ;				
					 			end	

					 		else
					 			begin
					 				out = B - A ;
					 				Odd_parity = ~^out ;				
					 			end	 
					 					
					 end 		
				3'b101 : 		
						begin
								if(red_op_A || red_op_B)
								Invalid = 1 ;
								else 
								Invalid = 0 ;
								
								if (!A && !B)
								out = {2*WIDTH {1'b0}} ; 

								else if(B == 0)
									begin
										out = -1;
										Invalid = 1 ;	
									end

								else
								out = A / B ;

							Odd_parity = ~^out;
						end

				default	:
						begin
							Invalid = 1 ; 
							out = 0 ;	
						end	

				endcase
			end	

end

endmodule


