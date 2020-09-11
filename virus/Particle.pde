class Particle{
  //float[] coor = new float[2];
  double[] coor;
  double[] velo;
  int particleType;
  int birthFrame;
  double AGE_GROW_SPEED = 0.08;
  Genome UGO_genome;
  
  public double[] getPos(){
    //return new double[]{coor[0],coor[1]};
    return coor;
  }
  
  public double getPos(int d){
    //return (double)coor[d];
    return coor[d];
  }
  
  public void setPos(double[] d){
    //coor[0] = (float)d[0];
    //coor[1] = (float)d[1];
    coor = d;
  }
  
  public void setPos(int i, double d){
    //coor[i] = (float)d;
    coor[i] = d;
  }
  
  public Particle(double[] tcoor, int ttype, int b){
    //coor = tcoor;
    setPos(tcoor);
    velo = getRandomVelo();
    particleType = ttype;
    UGO_genome = null;
    birthFrame = b;
  }
  public Particle(double[] tcoor, int ttype, String genomeString, int b){
    //coor = tcoor;
    setPos(tcoor);
    double dx = tcoor[2]-tcoor[0];
    double dy = tcoor[3]-tcoor[1];
    double dist = (float)Math.sqrt(dx*dx+dy*dy);
    double sp = (float)Math.random()*(SPEED_HIGH-SPEED_LOW)+SPEED_LOW;
    velo = new double[]{dx/dist*sp,dy/dist*sp};
    particleType = ttype;
    UGO_genome = new Genome(genomeString,true);
    birthFrame = b;
  }
  public double[] copyCoor(){
    double[] result = new double[2];
    for(int dim = 0; dim < 2; dim++){
      result[dim] = getPos(dim);
    }
    return result;
  }
  public void drawParticle(double x, double y, double s){
    pushMatrix();
    translate((float)x,(float)y);
    
    double ageScale = Math.min(1.0,(frameCount-birthFrame)*AGE_GROW_SPEED);
    scale((float)(s/BIG_FACTOR*ageScale));
    noStroke();
    if(particleType == VirusInfo.particle_type_food){
      fill(255,0,0);
    }else if(particleType == VirusInfo.particle_type_waste){
      fill(WASTE_COLOR);
    }else if(particleType == VirusInfo.particle_type_ugo){
      fill(0);
    }
    ellipseMode(CENTER);
    ellipse(0,0,0.1*BIG_FACTOR,0.1*BIG_FACTOR);
    if(UGO_genome != null){
      UGO_genome.drawCodons();
    }
    popMatrix();
  }
  double[] getRandomVelo(){
    double sp = (float)Math.random()*(SPEED_HIGH-SPEED_LOW)+SPEED_LOW;
    double ang = random(0,2*PI);
    double vx = sp*(float)Math.cos(ang);
    double vy = sp*(float)Math.sin(ang);
    double[] result = {vx, vy};
    return result;
  }
  public void loopCoor(int d){
    while(getPos(d) >= WORLD_SIZE){
      //coor[d] -= WORLD_SIZE;
      setPos(d, getPos(d) - WORLD_SIZE);
    }
    while(getPos(d) < 0){
      //coor[d] += WORLD_SIZE;
      setPos(d, getPos(d) + WORLD_SIZE);
    }
  }
  int particleCodonCount(){
    return (UGO_genome!=null)?UGO_genome.genomeCodonCount():0;
  }
}