class Cell{
  int x;
  int y;
  int cellType;
  double wallHealth;
  Genome genome;
  double geneTimer = 0;
  double energy = 0;
  double E_RECIPROCAL = 0.3678794411;
  boolean tampered = false;
  ArrayList<ArrayList<Particle>> particlesInCell = new ArrayList<ArrayList<Particle>>(0);
  
  ArrayList<double[]> laserCoor = new ArrayList<double[]>();
  Particle laserTarget = null;
  int laserT = -9999;
  int LASER_LINGER_TIME = 30;
  String memory = "";
  /*
  0: empty
  1: empty, inaccessible
  2: normal cell
  3: waste management cell
  4: gene-removing cell
  */
  int dire;
  
  int[] vars;
  int var;
  
  
  public Cell(int X_, int Y_, int type_, int dire_, double wallHealth_, String genome_){
    for(int j = 0; j < 3; j++){
      ArrayList<Particle> newList = new ArrayList<Particle>(0);
      particlesInCell.add(newList);
    }
    x = X_;
    y = Y_;
    cellType = type_;
    dire = dire_;
    wallHealth = wallHealth_;
    genome = new Genome(genome_,false);
    appRO = 0;
    appPO = 0;
    appDO = 0;
    rotateOn = (int)(Math.random()*getGenomeLength());
    geneTimer = (float)Math.random()*GENE_TICK_TIME;
    energy = 0.5;
    
    vars = new int[9];
    var = 0;
  }
  void drawCell(double x, double y, double s){
    pushMatrix();
    translate((float)x,(float)y);
    scale((float)(s/BIG_FACTOR));
    noStroke();
    if(cellType == VirusInfo.cell_type_wall){
      fill(60,60,60);
      rect(0,0,BIG_FACTOR,BIG_FACTOR);
    }else if(cellType == VirusInfo.cell_type_cell){
      if(this == selectedCell){
        fill(0,255,255);
      }else if(tampered){
        fill(205,225,70);
      }else{
        fill(225,190,225);
      }
      rect(0,0,BIG_FACTOR,BIG_FACTOR);
      fill(170,100,170);
      float w = (float)(BIG_FACTOR*0.08*wallHealth);
      rect(0,0,BIG_FACTOR,w);
      rect(0,BIG_FACTOR-w,BIG_FACTOR,w);
      rect(0,0,w,BIG_FACTOR);
      rect(BIG_FACTOR-w,0,w,BIG_FACTOR);
      
      pushMatrix();
      translate(BIG_FACTOR*0.5,BIG_FACTOR*0.5);
      stroke(0);
      strokeWeight(1);
      drawInterpreter();
      drawEnergy();
      genome.drawCodons();
      //genome.drawHand();
      drawHand();
      popMatrix();
    }
    popMatrix();
    if(cellType == VirusInfo.cell_type_cell){
      drawLaser();
    }
  }
  int rotateOn = 0;
  int performerOn = 0;
  int directionOn = VirusInfo.genome_hand_outward;
  double appRO = 0;
  double appPO = 0;
  double appDO = 0;
  double VISUAL_TRANSITION = 0.38;
  float HAND_DIST = 32;
  float HAND_LEN = 7;
  public void drawHand(){
    double appPOAngle = (float)(appPO*2*PI/getGenomeLength());
    double appDOAngle = (float)(appDO*PI);
    strokeWeight(1);
    noFill();
    stroke(transperize(handColor,0.5));
    ellipse(0,0,HAND_DIST*2,HAND_DIST*2);
    pushMatrix();
    rotate((float)appPOAngle);
    translate(0,-HAND_DIST);
    rotate((float)appDOAngle);
    noStroke();
    fill(handColor);
    beginShape();
    vertex(5,0);
    vertex(-5,0);
    vertex(0,-HAND_LEN);
    endShape(CLOSE);
    popMatrix();
  }
  public void drawInterpreter(){
    int GENOME_LENGTH = getGenomeLength();
    double CODON_ANGLE = (double)(1.0)/GENOME_LENGTH*2*PI;
    double INTERPRETER_SIZE = 23;
    double col = 1;
    double gtf = geneTimer/GENE_TICK_TIME;
    if(gtf < 0.5){
      col = Math.min(1,(0.5-gtf)*4);
    }
    pushMatrix();
    rotate((float)(-PI/2+CODON_ANGLE*appRO));//genome.appRO));
    fill((float)(col*255));
    beginShape();
    strokeWeight(BIG_FACTOR*0.01);
    stroke(80);
    vertex(0,0);
    vertex((float)(INTERPRETER_SIZE*Math.cos(CODON_ANGLE*0.5)),(float)(INTERPRETER_SIZE*Math.sin(CODON_ANGLE*0.5)));
    vertex((float)(INTERPRETER_SIZE*Math.cos(-CODON_ANGLE*0.5)),(float)(INTERPRETER_SIZE*Math.sin(-CODON_ANGLE*0.5)));
    endShape(CLOSE);
    popMatrix();
  }
  public void drawLaser(){
    if(frameCount < laserT+LASER_LINGER_TIME){
      double alpha = (double)((laserT+LASER_LINGER_TIME)-frameCount)/LASER_LINGER_TIME;
      stroke(transperize(handColor,alpha));
      strokeWeight((float)(0.033333*BIG_FACTOR));
      double[] handCoor = getHandCoor();
      if(laserTarget == null){
        for(double[] singleLaserCoor : laserCoor){
          daLine(handCoor,singleLaserCoor);
        }
      }else{
        double[] targetCoor = laserTarget.getPos();//laserTarget.coor
        daLine(handCoor,targetCoor);
      }
    }
  }
  public void drawEnergy(){
    noStroke();
    fill(0,0,0);
    ellipse(0,0,17,17);
    fill(255,255,0);
    pushMatrix();
    scale((float)Math.sqrt(energy));
    drawLightning();
    popMatrix();
  }
  public void drawLightning(){
    pushMatrix();
    scale(1.2);
    noStroke();
    beginShape();
    vertex(-1,-7);
    vertex(2,-7);
    vertex(0,-3);
    vertex(2.5,-3);
    vertex(0.5,1);
    vertex(3,1);
    vertex(-1.5,7);
    vertex(-0.5,3);
    vertex(-3,3);
    vertex(-1,-1);
    vertex(-4,-1);
    endShape(CLOSE);
    popMatrix();
  }
  public void iterate(){//PARTICLES ARE BAD
    if(getGenomeLength() != 0){
      if(cellType == VirusInfo.cell_type_cell){
        if(energy > 0){
          double oldGT = geneTimer;
          geneTimer -= PLAY_SPEED;
          if(geneTimer <= GENE_TICK_TIME/2.0 && oldGT > GENE_TICK_TIME/2.0){
            doAction();//PARTICLES ARE BAD
          }
          if(geneTimer <= 0){
            tickGene();
          }
        }
        appRO += loopIt(rotateOn-appRO, getGenomeLength(),true)*VISUAL_TRANSITION*PLAY_SPEED;
        appPO += loopIt(performerOn-appPO, getGenomeLength(),true)*VISUAL_TRANSITION*PLAY_SPEED;
        appDO += (directionOn-appDO)*VISUAL_TRANSITION*PLAY_SPEED;
        appRO = loopIt(appRO, getGenomeLength(),false);
        appPO = loopIt(appPO, getGenomeLength(),false);
      }
    }
  }
  public void doAction(){//PARTICLES ARE BAD
    Codon thisCodon = genome.getCodon(rotateOn%getGenomeLength());
    int[] info = thisCodon.codonInfo;
    if(info[VirusInfo.Codon_Major] != VirusInfo.Codon_Major_none || VirusInfo.UseEnergyForEmptyCodon == true){
      useEnergy();
    }
    switch(info[VirusInfo.Codon_Major])
    {
      case VirusInfo.Codon_Major_digest:
        switch(info[VirusInfo.Codon_Minor])
        {
          case VirusInfo.Codon_Minor_food:
          case VirusInfo.Codon_Minor_waste:
            Particle foodToEat = selectParticleInCell(info[VirusInfo.Codon_Minor]); // digest either "food" or "waste".
            if(foodToEat != null)
            {
              eat(foodToEat);//PARTICLES ARE BAD
            }
            break;
          
          case VirusInfo.Codon_Minor_wall:
            energy += (1-energy)*E_RECIPROCAL*0.2;
            hurtWall(26,VirusInfo.particle_type_none,0);//PARTICLES ARE BAD
            laserWall();
            break;
        }
        break;
      
      case VirusInfo.Codon_Major_remove:
        switch(info[VirusInfo.Codon_Minor])
        {
          case VirusInfo.Codon_Minor_food:
          case VirusInfo.Codon_Minor_waste:
            Particle wasteToPushOut = selectParticleInCell(info[VirusInfo.Codon_Minor]);
            if(wasteToPushOut != null)
            {
              pushOut(wasteToPushOut);//PARTICLES ARE BAD
            }
            break;
          
          case VirusInfo.Codon_Minor_wall:
            die();//PARTICLES ARE BAD
            break;
        }
        break;
      
      case VirusInfo.Codon_Major_repair:
        switch(info[VirusInfo.Codon_Minor])
        {
          case VirusInfo.Codon_Minor_food:
          case VirusInfo.Codon_Minor_waste:
            Particle particle = selectParticleInCell(info[VirusInfo.Codon_Minor]);
            shootLaserAt(particle);
            break;
          
          case VirusInfo.Codon_Minor_wall:
            healWall();
            break;
        }
        break;
      
      case VirusInfo.Codon_Major_moveHand:
        switch(info[VirusInfo.Codon_Minor])
        {
          case VirusInfo.Codon_Minor_weak:
            performerOn = genome.getWeakestCodon();
          break;
          
          case VirusInfo.Codon_Minor_inward:
            directionOn = VirusInfo.genome_hand_inward;
          break;
          
          case VirusInfo.Codon_Minor_outward:
            directionOn = VirusInfo.genome_hand_outward;
          break;
          
          case VirusInfo.Codon_Minor_rgl:
            performerOn = loopItInt(rotateOn+info[VirusInfo.Codon_RGL_Start],getGenomeLength());
          break;
        }
        break;
      
      case VirusInfo.Codon_Major_read:
        if(info[VirusInfo.Codon_Minor] == VirusInfo.Codon_Minor_rgl && directionOn == VirusInfo.genome_hand_inward)
        {
          readToMemory(info[VirusInfo.Codon_RGL_Start],info[3]);
        }
        break;
      
      case VirusInfo.Codon_Major_write:
        if(info[VirusInfo.Codon_Minor] == VirusInfo.Codon_Minor_rgl || directionOn == VirusInfo.genome_hand_outward)
        {
          writeFromMemory(info[VirusInfo.Codon_RGL_Start],info[VirusInfo.Codon_RGL_End]);//PARTICLES ARE BAD
        }
        break;
      
      case VirusInfo.Codon_Major_moveHead:
        rotateOn = info[VirusInfo.Codon_RGL_Start]%getGenomeLength();
        performerOn = rotateOn;
        break;
      
      case VirusInfo.Codon_Major_moveHead_rel:
        rotateOn = loopItInt(rotateOn + info[VirusInfo.Codon_RGL_Start], getGenomeLength());
        performerOn = rotateOn;
        break;
      
      case VirusInfo.Codon_Major_moveHead_rel_con:
        if(var == info[VirusInfo.Codon_RGL_Start]){
          rotateOn = loopItInt(rotateOn + info[VirusInfo.Codon_RGL_End], getGenomeLength());
          performerOn = rotateOn;
        }
        break;
      
      case VirusInfo.Codon_Major_var:
        switch(info[VirusInfo.Codon_Minor]){
          case VirusInfo.Codon_Minor_var_add:
            var += info[VirusInfo.Codon_RGL_End];
            break;
          
          case VirusInfo.Codon_Minor_var_sub:
            var -= info[VirusInfo.Codon_RGL_End];
            break;
          
          case VirusInfo.Codon_Minor_var_set:
            var = info[VirusInfo.Codon_RGL_End];
            break;
        }
        //println("var: " + var);
        break;
    }
    if(VirusInfo.CellCodonDecay == true){
      genome.hurtCodons();
    }
  }
  void useEnergy(){
    energy = Math.max(0,energy-(GENE_TICK_ENERGY * VirusInfo.CellEnergyUseMult));
  }
  void readToMemory(int start, int end){
    memory = "";
    laserTarget = null;
    laserCoor.clear();
    laserT = frameCount;
    for(int pos = start; pos <= end; pos++){
      int index = loopItInt(performerOn+pos,getGenomeLength());
      Codon c = genome.getCodon(index);
      memory = memory+c.infoToString();
      if(pos < end){
        memory = memory+"-";
      }
      laserCoor.add(getCodonCoor(index,genome.CODON_DIST));
    }
  }
  void writeFromMemory(int start, int end){//PARTICLES ARE BAD
    if(memory.length() == 0){
      return;
    }
    laserTarget = null;
    laserCoor.clear();
    laserT = frameCount;
    if(directionOn == VirusInfo.genome_hand_outward){
      writeOutwards();//PARTICLES ARE BAD
    }else{
      writeInwards(start,end);
    }
  }
  public void writeOutwards(){//PARTICLES ARE BAD
    double theta = (float)Math.random()*2*(float)Math.PI;
    double ugo_vx = (float)Math.cos(theta);
    double ugo_vy = (float)Math.sin(theta);
    double[] startCoor = getHandCoor();
    double[] newUGOcoor = new double[]{startCoor[0],startCoor[1],startCoor[0]+ugo_vx,startCoor[1]+ugo_vy};
    Particle newUGO = new Particle(newUGOcoor,VirusInfo.particle_type_ugo,memory,frameCount);
    particles.get(VirusInfo.particle_type_ugo).add(newUGO);//PARTICLES ARE BAD
    addToCellList(newUGO);//PARTICLES ARE BAD
    //addParticleToCell(newUGO);
    laserTarget = newUGO;
    
    String[] memoryParts = memory.split("-");
    for(int i = 0; i < memoryParts.length; i++){
      useEnergy();
    }
  }
  public void writeInwards(int start, int end){
    laserTarget = null;
    String[] memoryParts = memory.split("-");
    for(int pos = start; pos <= end; pos++){
      int index = loopItInt(performerOn+pos,getGenomeLength());
      Codon c = genome.getCodon(index);
      if(pos-start < memoryParts.length){
        String memoryPart = memoryParts[pos-start];
        c.setFullInfo(memoryPart);
        laserCoor.add(getCodonCoor(index,genome.CODON_DIST));
      }
      useEnergy();
    }
  }
  public void healWall(){
    wallHealth += (1-wallHealth)*E_RECIPROCAL;
    laserWall();
  }
  public void laserWall(){
    laserT = frameCount;
    laserCoor.clear();
    for(int i = 0; i < 4; i++){
      double[] result = {x+(i/2),y+(i%2)};
      laserCoor.add(result);
    }
    laserTarget = null;
  }
  public void eat(Particle food){//PARTICLES ARE BAD
    if(food.particleType == VirusInfo.particle_type_food){
      Particle newWaste = new Particle(food.getPos(),VirusInfo.particle_type_waste,-99999);//new Particle(food.coor,VirusInfo.particle_type_waste,-99999);
      shootLaserAt(newWaste);
      addToCellList(newWaste);//PARTICLES ARE BAD
      particles.get(VirusInfo.particle_type_waste).add(newWaste);//PARTICLES ARE BAD
      removeParticle(food);//PARTICLES ARE BAD
      //removeParticleFromCell(food);
      //addParticleToCell(newWaste);
      energy += (1-energy)*E_RECIPROCAL;
    }else{
      shootLaserAt(food);
    }
  }
  void shootLaserAt(Particle food){
    laserT = frameCount;
    laserTarget = food;
  }
  public double[] getHandCoor(){
    double r = HAND_DIST;
    if(directionOn == VirusInfo.genome_hand_outward){
      r += HAND_LEN;
    }else{
      r -= HAND_LEN;
    }
    return getCodonCoor(performerOn,r);
  }
  public double[] getCodonCoor(int i, double r){
    double theta = (float)(i*2*PI)/(getGenomeLength())-PI/2;
    double r2 = r/BIG_FACTOR;
    double handX = x+0.5+r2*(float)Math.cos(theta);
    double handY = y+0.5+r2*(float)Math.sin(theta);
    double[] result = {handX, handY};
    return result;
  }
  public void pushOut(Particle waste){//PARTICLES ARE BAD
    int[][] dire = {{0,1},{0,-1},{1,0},{-1,0}};
    int chosen = -1;
    while(chosen == -1 || cells[y+dire[chosen][1]][x+dire[chosen][0]].cellType != VirusInfo.cell_type_none){
      chosen = (int)random(0,4);
    }
    double[] oldCoor = waste.copyCoor();
    for(int dim = 0; dim < 2; dim++){
      if(dire[chosen][dim] == -1){
        waste.setPos(dim, Math.floor(waste.getPos(dim))-EPS);//waste.coor[dim] = Math.floor(waste.getPos(dim))-EPS;//waste.setPos(dim, Math.floor(waste.getPos(dim))-EPS);//waste.coor[dim] = Math.floor(waste.coor[dim])-EPS;//
        waste.velo[dim] = -Math.abs(waste.velo[dim]);
      }else if(dire[chosen][dim] == 1){
        waste.setPos(dim, Math.ceil(waste.getPos(dim))+EPS);//waste.coor[dim] = Math.ceil(waste.getPos(dim))+EPS;//waste.setPos(dim, Math.ceil(waste.getPos(dim))+EPS);//waste.coor[dim] = Math.ceil(waste.coor[dim])+EPS;//
        waste.velo[dim] = Math.abs(waste.velo[dim]);
      }
      waste.loopCoor(dim);
    }
    Cell p_cell = getCellAt(oldCoor,true);//PARTICLES ARE BAD
    p_cell.removeParticleFromCell(waste);//PARTICLES ARE BAD
    Cell n_cell = getCellAt(waste.getPos(),true);//PARTICLES ARE BAD//getCellAt(waste.coor,true);
    n_cell.addParticleToCell(waste);//PARTICLES ARE BAD
    laserT = frameCount;
    laserTarget = waste;
  }
  //public void pushOut(Particle waste){//PARTICLES ARE BAD
  //  int[][] dire = {{0,1},{0,-1},{1,0},{-1,0}};
  //  int chosen = -1;
  //  while(chosen == -1 || cells[y+dire[chosen][1]][x+dire[chosen][0]].cellType != VirusInfo.cell_type_none){
  //    chosen = (int)random(0,4);
  //  }
  //  double[] oldCoor = waste.copyCoor();
  //  for(int dim = 0; dim < 2; dim++){
  //    if(dire[chosen][dim] == -1){
  //      waste.coor[dim] = Math.floor(waste.coor[dim])-EPS;
  //      waste.velo[dim] = -Math.abs(waste.velo[dim]);
  //    }else if(dire[chosen][dim] == 1){
  //      waste.coor[dim] = Math.ceil(waste.coor[dim])+EPS;
  //      waste.velo[dim] = Math.abs(waste.velo[dim]);
  //    }
  //    waste.loopCoor(dim);
  //  }
  //  Cell p_cell = getCellAt(oldCoor,true);//PARTICLES ARE BAD
  //  p_cell.removeParticleFromCell(waste);//PARTICLES ARE BAD
  //  Cell n_cell = getCellAt(waste.coor,true);//PARTICLES ARE BAD
  //  n_cell.addParticleToCell(waste);//PARTICLES ARE BAD
  //  laserT = frameCount;
  //  laserTarget = waste;
  //}
  public void tickGene(){
    geneTimer += GENE_TICK_TIME;
    rotateOn = (rotateOn+1)%getGenomeLength();
  }
  public void hurtWall(double multi){//PARTICLES ARE BAD
    hurtWall(multi, VirusInfo.particle_type_none, 0);//PARTICLES ARE BAD
  }
  public void hurtWall(double multi, int particleType, int codonCount){//PARTICLES ARE BAD
    if(cellType >= VirusInfo.cell_type_cell){
      wallHealth -= (((WALL_DAMAGE*multi)*VirusInfo.CellWallDamageMult) / 10) * ((particleType != VirusInfo.particle_type_ugo) ? 10 : 10-10/codonCount);
      if(wallHealth <= 0){
        die();//PARTICLES ARE BAD
      }
    }
  }
  public void die(){//PARTICLES ARE BAD
    for(int i = 0; i < getGenomeLength(); i++){
      Particle newWaste = new Particle(getCodonCoor(i,genome.CODON_DIST),VirusInfo.particle_type_waste,-99999);
      addToCellList(newWaste);//PARTICLES ARE BAD
      particles.get(VirusInfo.particle_type_waste).add(newWaste);//PARTICLES ARE BAD
      //addParticleToCell(newWaste);
    }
    cellType = VirusInfo.cell_type_none;
    if(this == selectedCell){
      selectedCell = null;
    }
    if(tampered){
      cellCounts[1]--;
    }else{
      cellCounts[0]--;
    }
    cellCounts[2]++;
  }
  public void addParticleToCell(Particle food){
    particlesInCell.get(food.particleType).add(food);
  }
  public void removeParticleFromCell(Particle food){
    ArrayList<Particle> myList = particlesInCell.get(food.particleType);
    //myList.remove(food);
    for(int i = 0; i < myList.size(); i++){
      if(myList.get(i) == food){
        myList.remove(i);
      }
    }
  }
  public Particle selectParticleInCell(int type){
    ArrayList<Particle> myList = particlesInCell.get(type-1);
    if(myList.size() == 0){
      return null;
    }else{
      int choiceIndex = (int)(Math.random()*myList.size());
      return myList.get(choiceIndex);
    }
  }
  public String getCellName(){
    if(x == -1){
      return "Custom UGO";
    }else if(cellType == VirusInfo.cell_type_cell){
      return "Cell at ("+x+", "+y+")";
    }else{
      return "";
    }
  }
  public int getParticleCount(int t){
    if(t == -1){
      int sum = 0;
      for(int i = 0; i < 3; i++){
        sum += particlesInCell.get(i).size();
      }
      return sum;
    }else{
      return particlesInCell.get(t).size();
    }
  }
  public String getParticleCountString(int t, String s){
    return count(getParticleCount(t), s);
  }
  String count(int count, String s){
    if(count == 1){
      return count+" "+s;
    }else{
      return count+" "+s+"s";
    }
  }
  int getGenomeLength(){
    return (genome!=null)?genome.genomeCodonCount():0;
  }
  String getMemory(){
    if(memory.length() == 0){
      return "[NOTHING]";
    }else{
      return "\""+memory+"\"";
    }
  }
  double loopIt(double x, double len, boolean evenSplit){
    if(evenSplit){
      while(x >= len*0.5){
        x -= len;
      }
      while(x < -len*0.5){
        x += len;
      }
    }else{
      while(x > len-0.5){
        x -= len;
      }
      while(x < -0.5){
        x += len;
      }
    }
    return x;
  }
  int loopItInt(int x, int len){
    return (x+len*10)%len;
  }
  color transperize(color col, double trans){
    float alpha = (float)(trans*255);
    return color(red(col),green(col),blue(col),alpha);
  }
}