static class VirusInfo{
  public final static color TELOMERE_COLOR = #000000;
  public final static boolean UseEnergyForEmptyCodon = true;
  public final static int maxUGOLength = 9;//9
  public final static float CellEnergyUseMult = 1;
  public final static float CellWallDamageMult = 1;
  public final static boolean CellCodonDecay = true;
  
  static color[][] colors =
  {
    {
      #000000,#6400C8,#B4A00A,//none, digest, remove
      #009600,#C80064,#4646FF,//repair, move hand, read
      #0000DC,#C80064,#C80064,#C80064,//write, move head, move head rel, move head rel con
      #0000DC//var set/mod
    },
    {
      #000000,#C83232,#644100,#A050A0,//none, food, waste, wall
      #50B450,#006464,#00C8C8,//weak loc, inward, outward
      #8C8C8C,//rgl
      #8C8C8C,#8C8C8C,#8C8C8C,#5A5A5A,#5A5A5A//add, sub, set, rgl start, rgl end
    }
  };
  static String[][] names =
  {
    {
      "none","digest","remove","repair","move hand","read","write","move head","move head rel","beq rel","var"
    },
    {
      "none","food","waste","wall","weak loc","inward","outward","RGL","add","sub","set","- RGL start +","- RGL end +"
    }
  };
  
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                   DO NOT EDIT ANYTHING BELOW THIS!                                                //
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  public final static int cell_type_none = 0;
  public final static int cell_type_wall = 1;
  public final static int cell_type_cell = 2;
  
  public final static int particle_type_none = -1;
  public final static int particle_type_food = 0;
  public final static int particle_type_waste = 1;
  public final static int particle_type_ugo = 2;
  
  public final static int genome_hand_outward = 0;
  public final static int genome_hand_inward = 1;
  
  public final static int Codon_Edit_CR_None = -1;
  public final static int Codon_Edit_Col = 0;
  public final static int Codon_Edit_Row = 1;
  public final static int Codon_Edit_RGL_Start = 2;
  public final static int Codon_Edit_RGL_End = 3;
  
  public final static int Codon_Major = 0;
  public final static int Codon_Minor = 1;
  public final static int Codon_RGL_Start = 2;
  public final static int Codon_RGL_End = 3;
  
  public final static int Codon_Major_none = 0;
  public final static int Codon_Major_digest = 1;
  public final static int Codon_Major_remove = 2;
  public final static int Codon_Major_repair = 3;
  public final static int Codon_Major_moveHand = 4;
  public final static int Codon_Major_read = 5;
  public final static int Codon_Major_write = 6;
  public final static int Codon_Major_moveHead = 7;//jumps to absolute place
  public final static int Codon_Major_moveHead_rel = 8;//jumps relative to current place
  public final static int Codon_Major_moveHead_rel_con = 9;//jumps relative to current place in condition is met
  public final static int Codon_Major_var = 10;//set/mod variable
  
  public final static int Codon_Minor_none = 0;
  public final static int Codon_Minor_food = 1;
  public final static int Codon_Minor_waste = 2;
  public final static int Codon_Minor_wall = 3;
  public final static int Codon_Minor_weak = 4;
  public final static int Codon_Minor_inward = 5;
  public final static int Codon_Minor_outward = 6;
  public final static int Codon_Minor_rgl = 7;
  public final static int Codon_Minor_var_add = 8;
  public final static int Codon_Minor_var_sub = 9;
  public final static int Codon_Minor_var_set = 10;
  public final static int Codon_Minor_rgl_start = 11;
  public final static int Codon_Minor_rgl_end = 12;
  
  public final static String Codon_Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  
  public final static boolean[] Codon_Minor_HasExtraData = {false,false,false,false,false,false,false,true,true,true,true,false,false};
  
  public static int Codon_Char_value(char c){
    return Codon_Chars.indexOf(c);
  }
  
  public static int codonCharToVal(char c){
    return VirusInfo.Codon_Char_value(c)-30;
  }
  public static String codonValToChar(int i){
    return VirusInfo.Codon_Chars.charAt(i+30)+"";
  }
  public static String codonCharToValString(String s){
    String t = str(codonCharToVal(s.charAt(0)));
    t += str(codonCharToVal(s.charAt(1)));
    return t;
  }
  
  public static String infoToString(int[] info){
    String result = Codon_Chars.charAt(info[Codon_Major])+""+Codon_Chars.charAt(info[Codon_Minor]);
    if(Codon_Minor_HasExtraData[info[Codon_Minor]] == true){
      result += codonValToChar(info[Codon_RGL_Start])+""+codonValToChar(info[Codon_RGL_End]);
    }
    return result;
  }
  public static int[] stringToInfo(String str){
    int[] info = new int[4];
    if(str.length() < 1){
      return info;
    }
    for(int i = 0; i < 2; i++){
      info[i] = Codon_Char_value(str.charAt(i));
    }
    if(Codon_Minor_HasExtraData[info[Codon_Minor]] == true){
      for(int i = 2; i < 4; i++){
        char c = str.charAt(i);
        info[i] = codonCharToVal(c);
      }
    }
    return info;
  }

  public static color getColor(int p, int t){
    return VirusInfo.colors[p][t];
  }
  public static String getText(int p, int[] codonInfo){
    String result = VirusInfo.names[p][codonInfo[p]].toUpperCase();
    if(p == Codon_Minor && Codon_Minor_HasExtraData[codonInfo[Codon_Minor]]){
      result += " ("+codonInfo[Codon_RGL_Start]+" to "+codonInfo[Codon_RGL_End]+")";
    }
    return result;
  }
  public static String getTextSimple(int p, int t, int start, int end){
    String result = VirusInfo.names[p][t].toUpperCase();
    if(p == Codon_Minor && Codon_Minor_HasExtraData[t]){
      result += " ("+start+" to "+end+")";
    }
    return result;
  }
  public static int getOptionSize(int p){
    return names[p].length;
  }
}