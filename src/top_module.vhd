-------------------------------------------------------------------------------
-- Bitmap VGA display with 640x480 pixel resolution
-------------------------------------------------------------------------------
-- V 1.1.1 (2015/07/28)
-- Yannick Bornat (yannick.bornat@enseirb-matmeca.fr)
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

entity top_module is
  port(
		clk      : in  std_logic;
		reset    : in  std_logic;
      Hsync    : out std_logic;                     -- horisontal vga syncr.
      Vsync    : out std_logic;                     -- vertical vga syncr.
      vgaRed   : out std_logic_vector(3 downto 0);  -- red output
      vgaGreen : out std_logic_vector(3 downto 0);  -- green output
      vgaBlue  : out std_logic_vector(3 downto 0)   -- blue output
	);
end top_module;

architecture Behavioral of top_module is


begin

UUT : ENTITY WORK.VGA_bitmap_640x480
		GENERIC MAP(bit_per_pixel => 12, grayscale => false)
		PORT    MAP(
			clk        => clk,
			reset      => reset,
			VGA_hs     => Hsync,
			VGA_vs     => Vsync,
			VGA_red    => vgaRed,
			VGA_green  => vgaGreen,
			VGA_blue   => vgaBlue,
			ADDR       => (others => '0'),
			data_in    => (others => '0'),
			data_write => '0',
			data_out   => open
		);

end Behavioral;
