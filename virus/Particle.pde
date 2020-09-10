class Particle{
  double[] coor;
  double[] velo;
  int particleType;
  int birthFrame;
  double AGE_GROW_SPEED = 0.08;
  Genome UGO_genome;
  
  public Particle(double[] tcoor, int ttype, int b){
    coor = tcoor;
    velo = getRandomVelo();
    particleType = ttype;
    UGO_genome = null;
    birthFrame = b;
  }
  public Particle(double[] tcoor, int ttype, String genomeString, int b){
    coor = tcoor;
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
      result[dim] = coor[dim];
    }
    return result;
  }
  //public void moveDim(int d)
  //{
  //  float visc = (getCellTypeAt(coor,true) == 0) ? 1 : 0.5;
  //  double[] future = copyCoor();
  //  future[d] = coor[d]+velo[d]*visc*PLAY_SPEED;
  //  if(cellTransfer(coor, future)){
  //    int currentType = getCellTypeAt(coor,true);
  //    int futureType = getCellTypeAt(future,true);
  //    if(particleType == particle_type_ugo && currentType == cell_type_none && futureType == cell_type_cell && particleCodonCount()+getCellAt(future,true).getGenomeLength() <= MAX_CODON_COUNT)
  //    { // there are few enough codons that we can fit in the new material!
  //      injectGeneticMaterial(future);  // UGO is going to inject material into a cell!
  //    }
  //    else if(futureType == cell_type_wall || (particleType >= particle_type_waste && (currentType != cell_type_none || futureType != cell_type_none)))
  //    { // bounce
  //      Cell b_cell = getCellAt(future,true);
  //      if(b_cell.cellType >= cell_type_cell)
  //      {
  //        b_cell.hurtWall(1, particleType, particleCodonCount());
  //      }
  //      if(velo[d] >= 0)
  //      {
  //        velo[d] = -Math.abs(velo[d]);
  //        future[d] = (float)Math.ceil(coor[d])-EPS;
  //      }else
  //      {
  //        velo[d] = Math.abs(velo[d]);
  //        future[d] = (float)Math.floor(coor[d])+EPS;
  //      }
  //      Cell t_cell = getCellAt(coor,true);
  //      if(t_cell.cellType >= cell_type_cell)
  //      {
  //        t_cell.hurtWall(1, particleType, particleCodonCount());
  //      }
  //    }
  //    else
  //    {
  //      while(future[d] >= WORLD_SIZE)
  //      {
  //        future[d] -= WORLD_SIZE;
  //      }
  //      while(future[d] < 0)
  //      {
  //        future[d] += WORLD_SIZE;
  //      }
  //      hurtWalls(coor, future);
  //    }
  //  }
  //  coor = future;
  //}
  //public void injectGeneticMaterial(double[] futureCoor){
  //  Cell c = getCellAt(futureCoor,true);
  //  int injectionLocation = c.rotateOn;//c.genome.rotateOn;
  //  ArrayList<Codon> toInject = UGO_genome.codons;
  //  int INJECT_SIZE = particleCodonCount();
    
  //  for(int i = 0; i < toInject.size(); i++){
  //    int[] info = toInject.get(i).codonInfo;
  //    c.genome.codons.add(injectionLocation+i,new Codon(info,1.0));
  //  }
  //  if(c.performerOn >= c.rotateOn){
  //    c.performerOn += INJECT_SIZE;
  //  }
  //  c.rotateOn += INJECT_SIZE;
  //  tamper(c);
  //  removeParticle();
  //  //Should UGO injection create a waste particle?
  //  //Particle newWaste = new Particle(coor,particle_type_waste,-99999);
  //  //newWaste.addToCellList();
  //  //particles.get(1).add(newWaste);
  //}
  //public void hurtWalls(double[] coor, double[] future){
  //  Cell p_cell = getCellAt(coor,true);
  //  if(p_cell.cellType >= cell_type_cell){
  //    p_cell.hurtWall(1);
  //  }
  //  p_cell.removeParticleFromCell(this);
  //  Cell n_cell = getCellAt(future,true);
  //  if(n_cell.cellType >= cell_type_cell){
  //    n_cell.hurtWall(1);
  //  }
  //  n_cell.addParticleToCell(this);
  //}
  //public void iterate(){
  //  for(int dim = 0; dim < 2; dim++){
  //    moveDim(dim);
  //  }
  //}
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

  //public void removeParticle(){
  //  particles.get(particleType).remove(this);
  //  getCellAt(coor,true).particlesInCell.get(particleType).remove(this);
  //}
  //public void addToCellList(){
  //  Cell cellIn = getCellAt(coor,true);
  //  cellIn.addParticleToCell(this);
  //}
  public void loopCoor(int d){
    while(coor[d] >= WORLD_SIZE){
      coor[d] -= WORLD_SIZE;
    }
    while(coor[d] < 0){
      coor[d] += WORLD_SIZE;
    }
  }
  int particleCodonCount(){
    return (UGO_genome!=null)?UGO_genome.genomeCodonCount():0;
  }
}