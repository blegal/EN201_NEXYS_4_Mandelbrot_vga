-------------------------------------------------------------------------------
-- Bitmap VGA display with 640x480 pixel resolution
-------------------------------------------------------------------------------
-- V 1.1.2 (2015/11/29)
--  Bertrand Le Gal (bertrand.legal@enseirb-matmeca.fr)
--  Some little modifications to support data reading 
--  from file for RAM initilization.
--
-- V 1.1.1 (2015/07/28)
--  Yannick Bornat (yannick.bornat@enseirb-matmeca.fr)
--
-- For more information on this module, refer to module page :
--  http://bornat.vvv.enseirb.fr/wiki/doku.php?id=en202:vga_bitmap
-- 
-- V1.1.1 :
--   - Comment additions
--   - Code cleanup
-- V1.1.0 :
--   - added capacity above 3bpp
--   - ability to display grayscale pictures
--   - Module works @ 100MHz clock frequency
-- V1.0.1 :
--   - Fixed : image not centered on screen
-- V1.0.0 :
--   - Initial release
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use std.textio.ALL;

entity VGA_bitmap_640x480 is
  generic(bit_per_pixel : integer range 1 to 12:=1;    -- number of bits per pixel
          grayscale     : boolean := false);           -- should data be displayed in grayscale
  port(clk          : in  std_logic;
       reset        : in  std_logic;
       VGA_hs       : out std_logic;   -- horisontal vga syncr.
       VGA_vs       : out std_logic;   -- vertical vga syncr.
       VGA_red      : out std_logic_vector(3 downto 0);   -- red output
       VGA_green    : out std_logic_vector(3 downto 0);   -- green output
       VGA_blue     : out std_logic_vector(3 downto 0);   -- blue output

       ADDR         : in  std_logic_vector(18 downto 0);
       data_in      : in  std_logic_vector(bit_per_pixel - 1 downto 0);
       data_write   : in  std_logic;
       data_out     : out std_logic_vector(bit_per_pixel - 1 downto 0));
end VGA_bitmap_640x480;

architecture Behavioral of VGA_bitmap_640x480 is

	-- Graphic RAM type. this object is the content of the displayed image
	type GRAM is array (0 to 307199) of BIT_vector(bit_per_pixel - 1 downto 0); 

    impure function ram_function_name (ram_file_name : in string) return GRAM is                                                   
       FILE ram_file      : text is in ram_file_name;
       variable line_name : line;
       variable ram_name  : GRAM;
	 begin                                                        
       for I in GRAM'range loop                                  
           readline (ram_file, line_name);                             
           read (line_name, ram_name(I));                                  
       end loop;                                                    
       return ram_name;                                                  
	end function;                                                

	signal screen        : GRAM := ram_function_name("../mandelbrot.bin"); -- the memory representation of the image

	signal h_counter     : integer range 0 to 3199:=0;     -- counter for H sync. (size depends of frequ because of division)
	signal v_counter     : integer range 0 to 520 :=0;     -- counter for V sync. (base on v_counter, so no frequ issue)

	signal TOP_line      : boolean := false;               -- this signal is true when the current pixel column is visible on the screen
	signal TOP_display   : boolean := false;               -- this signal is true when the current pixel line is visible on the screen

	signal pix_read_addr : integer range 0 to 307199:=0;  -- the address at which displayed data is read

	signal next_pixel    : std_logic_vector(bit_per_pixel - 1 downto 0);  -- the data coding the value of the pixel to be displayed

begin


-- This process performs data access (read and write) to the memory
memory_management : process(clk)
begin
   if clk'event and clk='1' then
      next_pixel <= To_StdLogicVector( screen(pix_read_addr)              );
      data_out   <= To_StdLogicVector( screen(to_integer(unsigned(ADDR))) );
      if data_write = '1' then
         screen(to_integer(unsigned(ADDR))) <= TO_BitVector( data_in );
      end if;
   end if;
end process;


pixel_read_addr : process(clk)
begin
   if clk'event and clk='1' then
      if reset = '1' or (not TOP_display) then
         pix_read_addr <= 0;
      elsif TOP_line and (h_counter mod 4)=0 then
         pix_read_addr <= pix_read_addr + 1;
      end if;
   end if;
end process;


-- this process manages the horizontal synchro using the counters
process(clk)
begin
   if clk'event and clk='1' then
      if reset = '1' then
         VGA_vs    <= '0';
         TOP_display <= false;
      else
         case v_counter is
            when 0   => VGA_vs      <= '0';   -- start of Tpw   (  0 ->   0 +   1)
            when 2   => VGA_vs      <= '1';   -- start of Tbp   (  2 ->   2 +  28 =  30)
            when 31  => TOP_display <= true;  -- start of Tdisp ( 31 ->  31 + 479 = 510)  
            when 511 => TOP_display <= false; -- start of Tfp   (511 -> 511 +   9 = 520)
            when others   => null;
         end case;
--            if v_counter =   0 then VGA_vs      <= '0'; -- start of Tpw   (  0 ->   0 +   1)
--         elsif v_counter =   2 then VGA_vs      <= '1'; -- start of Tbp   (  2 ->   2 +  28 =  30)
--         elsif v_counter =  75 then TOP_display <= true; -- start of Tdisp ( 31 ->  31 + 479 = 510)
--         elsif v_counter = 475 then TOP_display <= false; -- start of Tfp   (511 -> 511 +   9 = 520)
--         end if;
      end if;
   end if;
end process;



process(clk)
begin
   if clk'event and clk='1' then
      if (not TOP_line) or (not TOP_display) then
         VGA_red   <= "0000";
         VGA_green <= "0000";
         VGA_blue  <= "0000";
      else
         case bit_per_pixel is
            when 1 =>
               VGA_red   <= (others => next_pixel(0));
               VGA_green <= (others => next_pixel(0));
               VGA_blue  <= (others => next_pixel(0));
            when 2 =>
               if grayscale then
                  VGA_blue  <= next_pixel & next_pixel;
                  VGA_green <= next_pixel & next_pixel;
                  VGA_red   <= next_pixel & next_pixel;
               else
                  VGA_red   <= (others => (next_pixel(0) and next_pixel(1)));
                  VGA_green <= (others => (next_pixel(1) and not next_pixel(0)));
                  VGA_blue  <= (others => (next_pixel(0) and not next_pixel(1)));
               end if;
            when 3 =>
               if grayscale then
                  VGA_blue  <= next_pixel & next_pixel(bit_per_pixel - 1);
                  VGA_green <= next_pixel & next_pixel(bit_per_pixel - 1);
                  VGA_red   <= next_pixel & next_pixel(bit_per_pixel - 1);
               else
                  VGA_red   <= (others => next_pixel(2));
                  VGA_green <= (others => next_pixel(1));
                  VGA_blue  <= (others => next_pixel(0));
               end if;
            when 4 =>
               if grayscale then
                  VGA_blue  <= next_pixel;
                  VGA_green <= next_pixel;
                  VGA_red   <= next_pixel;
               elsif next_pixel="1000" then
                  VGA_red   <= "0100";
                  VGA_green <= "0100";
                  VGA_blue  <= "0100";               
               else
                  VGA_red(2 downto 0)   <= (others => (next_pixel(2) and next_pixel(3)));
                  VGA_green(2 downto 0) <= (others => (next_pixel(1) and next_pixel(3)));
                  VGA_blue(2 downto 0)  <= (others => (next_pixel(0) and next_pixel(3)));
                  VGA_red(3)            <= next_pixel(2);
                  VGA_green(3)          <= next_pixel(1);
                  VGA_blue(3)           <= next_pixel(0);
               end if;
            when 5 => 
               case to_integer(unsigned(next_pixel)) is
                  when 0 | 3 | 6 |  9 | 12 | 15 | 18 | 21 | 24 => VGA_blue  <= "0000";
                  when 1 | 4 | 7 | 10 | 13 | 16 | 19 | 22 | 25 => VGA_blue  <= "1000";
                  when others                                  => VGA_blue  <= "1111";
               end case;
               case to_integer(unsigned(next_pixel)) is
                  when 0 | 1 | 2 |  9 | 10 | 11 | 18 | 19 | 20 => VGA_green  <= "0000";
                  when 3 | 4 | 5 | 12 | 13 | 14 | 21 | 22 | 23 => VGA_green  <= "1000";
                  when others                                  => VGA_green  <= "1111";
               end case;
               case to_integer(unsigned(next_pixel)) is
                  when 0 |  1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 => VGA_red  <= "0000";
                  when 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 => VGA_red  <= "1000";
                  when others                                    => VGA_red  <= "1111";
               end case;              
            when 6 => 
               VGA_red   <= next_pixel(5 downto 4) & next_pixel(5 downto 4);
               VGA_green <= next_pixel(3 downto 2) & next_pixel(3 downto 2);
               VGA_blue  <= next_pixel(1 downto 0) & next_pixel(1 downto 0);
            when 7 => 
               VGA_red   <= next_pixel(6 downto 5) & next_pixel(6 downto 5);
               VGA_green <= next_pixel(4 downto 2) & next_pixel(4);
               VGA_blue  <= next_pixel(1 downto 0) & next_pixel(1 downto 0);
            when 8 =>
               VGA_red   <= next_pixel(7 downto 5) & next_pixel(7);
               VGA_green <= next_pixel(4 downto 2) & next_pixel(4);
               VGA_blue  <= next_pixel(1 downto 0) & next_pixel(1 downto 0);
            when 9 =>
               VGA_red   <= next_pixel(8 downto 6) & next_pixel(8);
               VGA_green <= next_pixel(5 downto 3) & next_pixel(5);
               VGA_blue  <= next_pixel(2 downto 0) & next_pixel(2);
            when 10 =>
               VGA_red   <= next_pixel(9 downto 7) & next_pixel(9);
               VGA_green <= next_pixel(6 downto 3);
               VGA_blue  <= next_pixel(2 downto 0) & next_pixel(2);
            when 11 =>
               VGA_red   <= next_pixel(10 downto 7);
               VGA_green <= next_pixel( 6 downto 3);
               VGA_blue  <= next_pixel( 2 downto 0) & next_pixel(2);
            when 12 =>
               VGA_red   <= next_pixel(11 downto 8);
               VGA_green <= next_pixel( 7 downto 4);
               VGA_blue  <= next_pixel( 3 downto 0);
         end case;
      end if;
   end if;
end process;





-- this process manages the horizontal synchro using the counters
process(clk)
begin
   if clk'event and clk='1' then
      if reset = '1' then
         VGA_hs <= '0';
         TOP_line <= false;
      else
         case h_counter is
            when    2 => VGA_hs   <= '0';     -- start of Tpw   (  0  ->   0 +   95) -- +2 because of delay in RAM
            when  386 => VGA_hs   <= '1';     -- start of Tbp   (  96 ->   96 +  47 = 143) -- 384=96*4 -- -- +2 because of delay in RAM
            when  576 => TOP_line <= true;    -- start of Tdisp ( 144 ->  144 + 639 = 783)  -- 576=144*4
            when 3136 => TOP_line <= false;   -- start of Tfp   ( 784 ->  784 +  15 = 799) -- 3136 = 784*4
            when others => null;
         end case;
      
      
--         if    h_counter=2    then VGA_hs   <= '0';     -- start of Tpw   (  0  ->   0 +   95) -- +2 because of delay in RAM
--         elsif h_counter=386  then VGA_hs   <= '1';     -- start of Tbp   (  96 ->   96 +  47 = 143) -- 384=96*4 -- -- +2 because of delay in RAM
--         elsif h_counter=576  then TOP_line <= true;    -- start of Tdisp ( 144 ->  144 + 639 = 783)  -- 576=144*4
--         elsif h_counter=3136 then TOP_line <= false;   -- start of Tfp   ( 784 ->  784 +  15 = 799) -- 3136 = 784*4
--         end if;
      end if;
   end if;
end process;

-- counter management for synchro
process(clk)
begin
   if clk'event and clk='1' then
      if reset='1' then
         h_counter <= 0;
         v_counter <= 0;
      else
         if h_counter = 3199 then
            h_counter <= 0;
            if v_counter = 520 then
               v_counter <= 0;
            else
               v_counter <= v_counter + 1;
            end if;
         else
            h_counter <= h_counter +1;      
         end if;
      end if;
   end if;
end process;



end Behavioral;
