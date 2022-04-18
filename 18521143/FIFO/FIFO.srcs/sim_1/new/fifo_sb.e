<'
  struct fifo_sb {
      ! fifo : list of byte;
  
     addItem(data : byte) is {
       if (fifo.size() == 7) {
         outf("%dns : ERROR : Over flow detected, current occupancy %d\n",
           sys.time, fifo.size());
       } else {
         fifo.push(data);
       };
     };
  
     compareItem (data : byte) is {
       var cdata : byte = 0;
       if (fifo.size() == 0) {
         outf("%dns : ERROR : Under flow detected\n", sys.time);
       } else {
         cdata = fifo.pop0();
         if (data  ! = cdata) {
           outf("%dns : ERROR : Data mismatch, Expected %x Got %x\n", 
             sys.time, cdata, data );
         };
       };
     };
  };
  '>