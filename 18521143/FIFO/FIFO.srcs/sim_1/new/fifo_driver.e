<'
struct fifo_driver {
  sb : fifo_sb;

  rd_wt     : uint [0..100];
  rd_nop_wt : uint [0..100];
  wr_wt     : uint [0..100];
  wr_nop_wt : uint [0..100];

  keep soft wr_wt == 50;
  keep soft rd_wt == 100;
  keep soft wr_nop_wt == 100;
  keep soft rd_nop_wt == 50;

  rd        : bit;
  wr        : bit;

  rd_cmds    : uint;
    keep rd_cmds == 100;
  wr_cmds    : uint;
    keep wr_cmds == 100;

   ! rdDone : bool;
   ! wrDone : bool;
  
  monitorPush()@sys.clk is {
    var data : byte = 0;
    while (TRUE) {
      wait cycle;
      if ('top.wr_cs' == 1 &&  'top.wr_en' == 1) {
        data = 'top.data_in';
        sb.addItem(data);
        outf("%dns : Write posting to scoreboard data = %x\n",sys.time, data);
      };
    };
  };

  monitorPop()@sys.clk is {
    var data  : byte = 0;
    while (TRUE) {
      wait cycle;
      if ('top.rd_cs' == 1 &&  'top.rd_en' == 1) {
        data = 'top.data_out';
        sb.compareItem(data);
        outf("%dns : Read posting to scoreboard data = %x\n",sys.time, data);
      };
    };
  };

  go()@sys.clk is {
    // Assert reset first
    reset();
    // Start the monitors
    wait [5]*cycle;
    outf("%dns : Starting Pop and Push monitors\n",sys.time);
    start monitorPop();
    start monitorPush();
    outf("%dns : Starting Pop and Push generators\n",sys.time);
    start genPush();
    start genPop();

    while ( ! rdDone &&  ! wrDone) {
      wait cycle;
    };
    wait [10]*cycle;
    outf("%dns : Terminating simulations\n",sys.time);
    stop_run();
  };

  reset()@sys.clk is {
    wait [5]*cycle;
    outf("%dns : Asserting reset\n",sys.time);
    'top.rst' = 1'b1;
    // Init all variables
    rdDone = FALSE;
    wrDone = FALSE;
    wait [5]*cycle;
    'top.rst' = 1'b0;
    outf("%dns : Done asserting reset\n",sys.time);
  };

  genPush()@sys.clk is {
    var data : byte = 0;
    for {var i : uint = 0; i < wr_cmds; i = i + 1} do {
       gen wr keeping {
         soft it == select {
           wr_wt     : 1;
           wr_nop_wt : 0;
         };
       };
       gen data;
       wait cycle;
       while ('top.full' == 1'b1) {
        'top.wr_cs'   = 1'b0;
        'top.wr_en'   = 1'b0;
        'top.data_in' = 8'b0;
        wait cycle; 
       };
       if (wr == 1) {
         'top.wr_cs'   = 1'b1;
         'top.wr_en'   = 1'b1;
         'top.data_in' = data;
       } else {
         'top.wr_cs'   = 1'b0;
         'top.wr_en'   = 1'b0;
         'top.data_in' = 8'b0;
       };
    };
    wait cycle;
    'top.wr_cs'   = 1'b0;
    'top.wr_en'   = 1'b0;
    'top.data_in' = 8'b0;
    wait [10]*cycle;
    wrDone = TRUE;
  };
  
  genPop()@sys.clk is {
    for {var i : uint = 0; i < rd_cmds; i = i + 1} do {
       gen rd keeping {
         soft it == select {
           rd_wt     : 1;
           rd_nop_wt : 0;
         };
       };
       wait cycle;
       while ('top.empty' == 1'b1) {
        'top.rd_cs'   = 1'b0;
        'top.rd_en'   = 1'b0;
        wait cycle; 
       };
       if (rd == 1) {
         'top.rd_cs'   = 1'b1;
         'top.rd_en'   = 1'b1;
       } else {
         'top.rd_cs'   = 1'b0;
         'top.rd_en'   = 1'b0;
       };
    };
    wait cycle;
    'top.rd_cs'   = 1'b0;
    'top.rd_en'   = 1'b0;
    wait [10]*cycle;
    rdDone = TRUE;
  };
};
'>