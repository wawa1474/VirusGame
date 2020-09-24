class Genome{
  ArrayList<Codon> codons;
  
  double CODON_DIST = 17;
  boolean isUGO;
  
  public Genome(String s, boolean isUGOp){
    codons = new ArrayList<Codon>();
    String[] parts = (s!=null)?s.split(VirusInfo.Codon_Delim):new String[0];
    for(int i = 0; i < parts.length; i++){
      int[] info = VirusInfo.stringToInfo(parts[i]);
      codons.add(new Codon(info,1.0));
    }
    isUGO = isUGOp;
    if(isUGO){
      CODON_DIST = 10.6;
    }
  }
  public void drawCodons(){
    int VIS_GENOME_LENGTH = max(4,genomeCodonCount());
    for(int i = 0; i < genomeCodonCount(); i++){
      getCodon(i).draw(CODON_DIST, VIS_GENOME_LENGTH, i);
    }
  }
  public void hurtCodons(){
    for(int i = 0; i < genomeCodonCount(); i++){
      Codon c = getCodon(i);
      if(c.hasSubstance()){
        c.hurt();
      }
    }
  }
  public int getWeakestCodon(){
    double record = 9999;
    int holder = -1;
    for(int i = 0; i < genomeCodonCount(); i++){
      double val = getCodon(i).codonHealth;
      if(val < record){
        record = val;
        holder = i;
      }
    }
    return holder;
  }
  public String getGenomeString(){
    String str = "";
    for(int i = 0; i < genomeCodonCount(); i++){
      Codon c = getCodon(i);
      str = str+c.infoToString();
      if(i < genomeCodonCount()-1){
        str = str+VirusInfo.Codon_Delim;
      }
    }
    return str;
  }
  public String getGenomeStringShortened(){
    int limit = max(1,genomeCodonCount()-1);
    String str = "";
    for(int i = 0; i < limit; i++){
      Codon c = getCodon(i);
      str = str+c.infoToString();
      if(i < limit-1){
        str = str+VirusInfo.Codon_Delim;
      }
    }
    return str;
  }
  public String getGenomeStringLengthened(){
    if(genomeCodonCount() == VirusInfo.maxUGOLength){
      return getGenomeString();
    }else{
      return getGenomeString()+VirusInfo.Codon_Delim+VirusInfo.Codon_None_None;//"-AA";
    }
  }
  public int genomeCodonCount(){
    return (codons!=null)?codons.size():0;
  }
  public Codon getCodon(int i){
    int len = genomeCodonCount();
    return (codons != null && len != 0 || i >= len)?codons.get(i):null;
  }
  public ArrayList<Codon> getCodons(){
    return codons;
  }
  public void addCodon(Codon c){
    codons.add(c);
  }
  public void addCodon(int i, Codon c){
    codons.add(i, c);
  }
}