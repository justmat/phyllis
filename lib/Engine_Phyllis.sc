Engine_Phyllis : CroneEngine {
  var <synth;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    SynthDef(\Filter, {
      arg inL, inR, out, freq=440.0, res=0.1, inputGain=1.0, fType=0.0, noiseLevel=0.0003;
      var in, sig;
      
      in = [In.ar(inL), In.ar(inR)];
      
      sig = {
        DFM1.ar(in,
          freq,
          res,
          inputGain,
          fType,
          noiseLevel
        ); 
      };

      Out.ar(out, sig.softclip);
    }).add;

    context.server.sync;

    synth = Synth.new(\Filter, [
      \inL, context.in_b[0].index,			
			\inR, context.in_b[1].index,
      \out, context.out_b.index],
    context.xg);

    this.addCommand("freq", "f", {|msg|
      synth.set(\freq, msg[1]);
    });
    
    this.addCommand("res", "f", {|msg|
      synth.set(\res, msg[1]);
    }); 

    this.addCommand("gain", "f", {|msg|
      synth.set(\inputGain, msg[1]);
    });

    this.addCommand("type", "f", {|msg|
      synth.set(\fType, msg[1]);
    });

    this.addCommand("noise", "f", {|msg|
      synth.set(\noiseLevel, msg[1]);
    });
  }

  free {
    synth.free;
  }
}

