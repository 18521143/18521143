<'
 import fifo_clk.e;
 import fifo_sb.e;
 import fifo_driver.e;
 
 struct fifo_tb {
   scoreboard : fifo_sb;
 
   driver     : fifo_driver;
     keep driver.sb == scoreboard;
 
   go()@sys.clk is {
      start driver.go();
   };
 };
 
 extend sys {
   tb  : fifo_tb;
   run() is also {
     start tb.go();
   };
 };
 '>