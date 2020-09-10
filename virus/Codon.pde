class Codon{
  public int[] codonInfo = new int[4];
  double codonHealth;
  double CODON_WIDTH = 1.4;
  double[][] codonShape = {{-2,0},{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,0},{0,0}};
  double[][] telomereShape = {{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,-2},{1,-3},{0,-3},{-1,-3},{-2,-2}};
  public Codon(int[] info, double health){
    codonInfo = info;
    codonHealth = health;
  }
  public color getColor(int p){
    return VirusInfo.getColor(p,codonInfo[p]);
  }
  public String getText(int p){
    return VirusInfo.getText(p,codonInfo);
  }
  public boolean hasSubstance(){
    return (codonInfo[VirusInfo.Codon_Major] != VirusInfo.Codon_Major_none || codonInfo[VirusInfo.Codon_Minor] != VirusInfo.Codon_Minor_none);
  }
  public void hurt(){
    if(hasSubstance()){
      codonHealth -= Math.random()*CODON_DEGRADE_SPEED;
      if(codonHealth <= 0){
        codonHealth = 1;
        codonInfo[VirusInfo.Codon_Major] = VirusInfo.Codon_Major_none;
        codonInfo[VirusInfo.Codon_Minor] = VirusInfo.Codon_Minor_none;
      }
    }
  }
  public void setInfo(int p, int val){
    codonInfo[p] = val;
    codonHealth = 1.0;
  }
  public void setFullInfo(int[] info){
    codonInfo = info;
    codonHealth = 1.0;
  }
  public void setFullInfo(String info){
    setFullInfo(VirusInfo.stringToInfo(info));
  }
  public void draw(double CODON_DIST, int VIS_GENOME_LENGTH, int i){
    double CODON_ANGLE = (double)(1.0)/VIS_GENOME_LENGTH*2*PI;
    double PART_ANGLE = CODON_ANGLE/5.0;
    double baseAngle = -PI/2+i*CODON_ANGLE;
    pushMatrix();
    rotate((float)(baseAngle));
    
    //Codon c = codons.get(i);
    if(codonHealth != 1.0){
      beginShape();
      fill(VirusInfo.TELOMERE_COLOR);
      for(int v = 0; v < telomereShape.length; v++){
        double[] cv = telomereShape[v];
        double ang = cv[0]*PART_ANGLE;
        double dist = cv[1]*CODON_WIDTH+CODON_DIST;
        vertex((float)(Math.cos(ang)*dist),(float)(Math.sin(ang)*dist));
      }
    }
    endShape(CLOSE);
    for(int p = 0; p < 2; p++){
      beginShape();
      fill(getColor(p));
      for(int v = 0; v < codonShape.length; v++){
        double[] cv = codonShape[v];
        double ang = cv[0]*PART_ANGLE*codonHealth;
        double dist = cv[1]*(2*p-1)*CODON_WIDTH+CODON_DIST;
        vertex((float)(Math.cos(ang)*dist),(float)(Math.sin(ang)*dist));
      }
      endShape(CLOSE);
    }
    popMatrix();
  }
  public String infoToString(){
    return VirusInfo.infoToString(codonInfo);
  }
}