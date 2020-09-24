boolean DoSimCells = true;

int WORLD_SIZE = 12;
int W_W = 1728;
int W_H = 972;
Cell[][] cells = new Cell[WORLD_SIZE][WORLD_SIZE];
ArrayList<ArrayList<Particle>> particles = new ArrayList<ArrayList<Particle>>(0);
int foodLimit = 180;
float BIG_FACTOR = 100;
float PLAY_SPEED = 0.6;
double GENE_TICK_TIME = 40.0;
double margin = 4;
int START_LIVING_COUNT = 0;
int[] cellCounts = {0,0,0};

double REMOVE_WASTE_SPEED_MULTI = 0.001;
double removeWasteTimer = 1.0;

double GENE_TICK_ENERGY = 0.014;
double WALL_DAMAGE = 0.01;
double CODON_DEGRADE_SPEED = 0.008;
double EPS = 0.00000001;

//String starterGenome = "46-11-22-33-11-22-33-45-44-57__-67__";
//String starterGenome = "46-11-22-33-11-22-33-45-44-57__-67__";
String starterGenome =   "EG-BB-CC-DD-BB-CC-DD-EF-EE-FHee-GHee";
//String starterGenome;
//String starterGenome = "46-11-22-33-45-44-57__-67__";
//String starterGenome = "00";
boolean canDrag = false;
double clickWorldX = -1;
double clickWorldY = -1;
boolean DQclick = false;
int[] codonToEdit = {VirusInfo.Codon_Edit_CR_None,VirusInfo.Codon_Edit_CR_None,0,0};
double[] genomeListDims = {70,430,360,450};
double[] editListDims = {550,430,180,450};
double[] arrowToDraw = null;
Cell selectedCell = null;
Cell UGOcell;
int lastEditTimeStamp = 0;
color handColor = color(0,128,0);
color WASTE_COLOR = color(100,65,0);
//int MAX_CODON_COUNT = 20; // If a cell were to have more codons in its DNA than this number if it were to absorb a cirus particle, it won't absorb it.
int MAX_CODON_COUNT = 20;

double SPEED_LOW = 0.01;
double SPEED_HIGH = 0.02;
double MIN_ARROW_LENGTH_TO_PRODUCE = 0.4;

boolean wasMouseDown = false;
double camX = 0;
double camY = 0;
double MIN_CAM_S = ((float)W_H)/WORLD_SIZE;//972/12 = 81
double camS = MIN_CAM_S;

double ZOOM_THRESHOLD = 0;//80;
PFont font;
void setup(){
  font = loadFont("Jygquip1-96.vlw");
  setupWorld();
  //for(int j = 0; j < 3; j++){
  //  ArrayList<Particle> newList = new ArrayList<Particle>(0);
  //  particles.add(newList);
  //}
  //for(int y = 0; y < WORLD_SIZE; y++){
  //  for(int x = 0; x < WORLD_SIZE; x++){
  //    int t = getTypeFromXY(x,y);
  //    cells[y][x] = new Cell(x,y,t,0,1,starterGenome);
  //    if(t == 2){
  //      START_LIVING_COUNT++;
  //      cellCounts[0]++;
  //    }
  //  }
  //}
  size(1728,972);
  noSmooth();
  //UGOcell = new Cell(-1,-1,VirusInfo.cell_type_cell,0,1,"AA-AA-AA-AA-AA");//EF-EHee-FHdh-EG-GA
  UGOcell = new Cell(-1,-1,VirusInfo.cell_type_cell,0,1,"EF-EHee-FHdh-EG-GA");//EF-EHee-FHdh-EG-GA
}
void setupWorld(){
  frameCount = 0;
  lastEditTimeStamp = 0;
  START_LIVING_COUNT=0;
  cellCounts = new int[]{0,0,0};
  particles = new ArrayList<ArrayList<Particle>>(0);
  for(int j = 0; j < 3; j++){
    ArrayList<Particle> newList = new ArrayList<Particle>(0);
    particles.add(newList);
  }
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      int t = getTypeFromXY(x,y);
      cells[y][x] = new Cell(x,y,t,0,1,starterGenome);
      if(t == 2){
        START_LIVING_COUNT++;
        cellCounts[0]++;
      }
    }
  }
}
void draw(){
  if(key == 'r'){
    setupWorld();
    key = ' ';
  }
  if(key == 't'){
    println(selectedCell.memory);
    key = ' ';
  }
  if(key == 'y'){
    println(selectedCell.genome.getGenomeString());
    key = ' ';
  }
  doParticleCountControl();
  if(DoSimCells == true){
    iterate();
  }
  detectMouse();
  drawBackground();
  drawCells();
  drawParticles();
  drawExtras();
  drawUI();
}
void keyPressed(){
  if(key == 'q'){
    DoSimCells = !DoSimCells;
  }
}
void drawExtras(){
  if(arrowToDraw != null){
    if(euclidLength(arrowToDraw) > MIN_ARROW_LENGTH_TO_PRODUCE){
      stroke(0);
    }else{
      stroke(0,0,0,80);
    }
    drawArrow(arrowToDraw[0],arrowToDraw[1],arrowToDraw[2],arrowToDraw[3]);
  }
}
void iterate(){
  for(int z = 0; z < 3; z++){
    ArrayList<Particle> sparticles = particles.get(z);
    for(int i = 0; i < sparticles.size(); i++){
      Particle p = sparticles.get(i);
      //p.iterate();
      iterateParticle(p);
    }
  }
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      cells[y][x].iterate();//PARTICLES ARE BAD
    }
  }
}
void drawParticles(){
  for(int z = 0; z < 3; z++){
    ArrayList<Particle> sparticles = particles.get(z);
    for(int i = 0; i < sparticles.size(); i++){
      Particle p = sparticles.get(i);
      p.drawParticle(trueXtoAppX(p.getPos(0)),trueYtoAppY(p.getPos(1)),trueStoAppS(1));//p.coor[0]
    }
  }
}
void checkGLclick(){
  double gx = genomeListDims[0];
  double gy = genomeListDims[1];
  double gw = genomeListDims[2];
  double gh = genomeListDims[3];
  double rMouseX = ((mouseX-W_H)-gx)/gw;
  double rMouseY = (mouseY-gy)/gh;
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0){
    if(rMouseY < 1){
      codonToEdit[VirusInfo.Codon_Edit_Col] = (int)(rMouseX*2);
      codonToEdit[VirusInfo.Codon_Edit_Row] = (int)(rMouseY*selectedCell.getGenomeLength());
      //println("Col:" + codonToEdit[Codon_Col] + " - Row:" + codonToEdit[Codon_Row]);
    }else if(selectedCell == UGOcell){
      if(rMouseX < 0.5){
        String genomeString = UGOcell.genome.getGenomeStringShortened();
        selectedCell = UGOcell = new Cell(-1,-1,VirusInfo.cell_type_cell,0,1,genomeString);
      }else{
        String genomeString = UGOcell.genome.getGenomeStringLengthened();
        selectedCell = UGOcell = new Cell(-1,-1,VirusInfo.cell_type_cell,0,1,genomeString);
      }
    }
  }
}
void checkETclick(){
  double ex = editListDims[0];
  double ey = editListDims[1];
  double ew = editListDims[2];
  double eh = editListDims[3];
  double rMouseX = ((mouseX-W_H)-ex)/ew;
  double rMouseY = (mouseY-ey)/eh;
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0 && rMouseY < 1){
    int optionCount = VirusInfo.getOptionSize(codonToEdit[VirusInfo.Codon_Edit_Col]);
    int choice = (int)(rMouseY*optionCount);
    if(codonToEdit[VirusInfo.Codon_Edit_Col] == VirusInfo.Codon_Minor && choice >= optionCount-2){
      int diff = 1;
      if(rMouseX < 0.5){
        diff = -1;
      }
      if(choice == optionCount-2){
        codonToEdit[VirusInfo.Codon_Edit_RGL_Start] = loopCodonInfo(codonToEdit[VirusInfo.Codon_Edit_RGL_Start]+diff);
      }else{
        codonToEdit[VirusInfo.Codon_Edit_RGL_End] = loopCodonInfo(codonToEdit[VirusInfo.Codon_Edit_RGL_End]+diff);
      }
    }else{
      Codon thisCodon = selectedCell.genome.getCodon(codonToEdit[VirusInfo.Codon_Edit_Row]);
      if(codonToEdit[VirusInfo.Codon_Edit_Col] == VirusInfo.Codon_Minor && VirusInfo.Codon_Minor_HasExtraData[choice]){
        if(thisCodon.codonInfo[VirusInfo.Codon_Minor] != choice ||
        thisCodon.codonInfo[VirusInfo.Codon_RGL_Start] != codonToEdit[VirusInfo.Codon_Edit_RGL_Start] || thisCodon.codonInfo[VirusInfo.Codon_RGL_End] != codonToEdit[VirusInfo.Codon_Edit_RGL_End]){
          thisCodon.setInfo(VirusInfo.Codon_Minor,choice);
          thisCodon.setInfo(VirusInfo.Codon_RGL_Start,codonToEdit[VirusInfo.Codon_Edit_RGL_Start]);
          thisCodon.setInfo(VirusInfo.Codon_RGL_End,codonToEdit[VirusInfo.Codon_Edit_RGL_End]);
          if(selectedCell != UGOcell){
            lastEditTimeStamp = frameCount;
            tamper(selectedCell);
          }
        }
      }else{
        if(thisCodon.codonInfo[codonToEdit[VirusInfo.Codon_Edit_Col]] != choice){
          thisCodon.setInfo(codonToEdit[VirusInfo.Codon_Edit_Col],choice);
          if(selectedCell != UGOcell){
            lastEditTimeStamp = frameCount;
            tamper(selectedCell);
          }
        }
      }
    }
  }else{
    codonToEdit[VirusInfo.Codon_Edit_Col] = codonToEdit[VirusInfo.Codon_Edit_Row] = VirusInfo.Codon_Edit_CR_None;
  }
}
void detectMouse(){
  if (mousePressed){
    arrowToDraw = null;
    if(!wasMouseDown) {
      if(mouseX < W_H){
        codonToEdit[VirusInfo.Codon_Edit_Col] = codonToEdit[VirusInfo.Codon_Edit_Row] = VirusInfo.Codon_Edit_CR_None;
        clickWorldX = appXtoTrueX(mouseX);
        clickWorldY = appYtoTrueY(mouseY);
        canDrag = true;
      }else{
        if(selectedCell != null){
          if(codonToEdit[VirusInfo.Codon_Edit_Col] >= 0){
            checkETclick();
          }
          checkGLclick();
        }
        if(selectedCell == UGOcell){
          if((mouseX >= W_H+530 && codonToEdit[VirusInfo.Codon_Edit_Col] == VirusInfo.Codon_Edit_CR_None) || mouseY < 160){
            selectedCell = null;
          }
        }else if(mouseX > W_W-160 && mouseY < 160){
          selectedCell = UGOcell;
        }
        canDrag = false;
      }
      DQclick = false;
    }else if(canDrag){
      double newCX = appXtoTrueX(mouseX);
      double newCY = appYtoTrueY(mouseY);
      if(newCX != clickWorldX || newCY != clickWorldY){
        DQclick = true;
      }
      if(selectedCell == UGOcell){
        stroke(0,0,0);
        arrowToDraw = new double[]{clickWorldX,clickWorldY,newCX,newCY};
      }else{
        camX -= (newCX-clickWorldX);
        camY -= (newCY-clickWorldY);
      }
    }
  }
  if(!mousePressed){
    if(wasMouseDown){
      if(selectedCell == UGOcell && arrowToDraw != null){
        if(euclidLength(arrowToDraw) > MIN_ARROW_LENGTH_TO_PRODUCE){
          produceUGO(arrowToDraw);
        }
      }
      if(!DQclick && canDrag){
        double[] mCoor = {clickWorldX,clickWorldY};
        Cell clickedCell = getCellAt(mCoor,false);
        if(selectedCell != UGOcell){
          selectedCell = null;
        }
        if(clickedCell != null && clickedCell.cellType == VirusInfo.cell_type_cell){
          selectedCell = clickedCell;
        }
      }
    }
    clickWorldX = -1;
    clickWorldY = -1;
    arrowToDraw = null;
  }
  wasMouseDown = mousePressed;
}
void mouseWheel(MouseEvent event) {
  double ZOOM_F = 1.05;
  double thisZoomF = 1;
  double e = event.getCount();
  if(e == 1){
    thisZoomF = 1/ZOOM_F;
  }else{
    thisZoomF = ZOOM_F;
  }
  double worldX = mouseX/camS+camX;
  double worldY = mouseY/camS+camY;
  camX = (camX-worldX)/thisZoomF+worldX;
  camY = (camY-worldY)/thisZoomF+worldY;
  camS *= thisZoomF;
}
void drawBackground(){
  background(255);
}
void drawArrow(double dx1, double dx2, double dy1, double dy2){
  float x1 = (float)trueXtoAppX(dx1);
  float y1 = (float)trueYtoAppY(dx2);
  float x2 = (float)trueXtoAppX(dy1);
  float y2 = (float)trueYtoAppY(dy2);
  strokeWeight((float)(0.03*camS));
  line(x1,y1,x2,y2);
  float angle = atan2(y2-y1,x2-x1);
  float head_size = (float)(0.2*camS);
  float x3 = x2+head_size*cos(angle+PI*0.8);
  float y3 = y2+head_size*sin(angle+PI*0.8);
  line(x2,y2,x3,y3);
  float x4 = x2+head_size*cos(angle-PI*0.8);
  float y4 = y2+head_size*sin(angle-PI*0.8);
  line(x2,y2,x4,y4);
}
void drawUI(){
  pushMatrix();
  translate(W_H,0);
  fill(0);
  noStroke();
  rect(0,0,W_W-W_H,W_H);
  fill(255);
  textFont(font,48);
  textAlign(LEFT);
  text(framesToTime(frameCount)+" start",25,60);
  text(framesToTime(frameCount-lastEditTimeStamp)+" edit",25,108);
  textFont(font,36);
  text("Healthy: "+cellCounts[0]+" / "+START_LIVING_COUNT,360,50);
  text("Tampered: "+cellCounts[1]+" / "+START_LIVING_COUNT,360,90);
  text("Dead: "+cellCounts[2]+" / "+START_LIVING_COUNT,360,130);
  if(selectedCell != null){
    drawCellStats();
  }
  popMatrix();
  drawUGObutton((selectedCell != UGOcell));
}
void drawUGObutton(boolean drawUGO){
  fill(80);
  noStroke();
  rect(W_W-130,10,120,140);
  fill(255);
  textAlign(CENTER);
  if(drawUGO){
    textFont(font,48);
    text("MAKE",W_W-70,70);
    text("UGO",W_W-70,120);
  }else{
    textFont(font,36);
    text("CANCEL",W_W-70,95);
  }
}
void drawCellStats(){
  boolean isUGO = (selectedCell.x == -1);
  fill(80);
  noStroke();
  rect(10,160,530,W_H-170);
  if(!isUGO){
    rect(540,160,200,270);
  }
  fill(255);
  textFont(font,96);
  textAlign(LEFT);
  text(selectedCell.getCellName(),25,255);
  if(!isUGO){
    textFont(font,32);
    text("Inside this cell,",555,200);
    text("there are:",555,232);
    text(selectedCell.getParticleCountString(VirusInfo.particle_type_none,"particle"),555,296);
    text("("+selectedCell.getParticleCountString(VirusInfo.particle_type_food,"food")+")",555,328);
    text("("+selectedCell.getParticleCountString(VirusInfo.particle_type_waste,"waste")+")",555,360);
    text("("+selectedCell.getParticleCountString(VirusInfo.particle_type_ugo,"UGO")+")",555,392);
    drawBar(color(255,255,0),selectedCell.energy,"Energy",290);
    drawBar(color(210,50,210),selectedCell.wallHealth,"Wall health",360);
  }
  drawGenomeAsList(selectedCell.genome,genomeListDims, selectedCell.appRO);
  drawEditTable(editListDims);
  if(!isUGO){
    textFont(font,32);
    textAlign(LEFT);
    text("Memory: "+selectedCell.getMemory(),25,940);
  }
}
void drawGenomeAsList(Genome g, double[] dims, double appRO){
  double x = dims[0];
  double y = dims[1];
  double w = dims[2];
  double h = dims[3];
  int GENOME_LENGTH = g.genomeCodonCount();//codons.size();
  double appCodonHeight = h/GENOME_LENGTH;
  double appW = w*0.5-margin;
  textFont(font,30);
  textAlign(CENTER);
  pushMatrix();
  dTranslate(x,y);
  pushMatrix();
  dTranslate(0,appCodonHeight*(appRO+0.5));//g.appRO+0.5));
  if(selectedCell != UGOcell){
    drawGenomeArrows(w,appCodonHeight);
  }
  popMatrix();
  for(int i = 0; i < GENOME_LENGTH; i++){
    double appY = appCodonHeight*i;
    Codon codon = g.getCodon(i);//codons.get(i);
    for(int p = 0; p < 2; p++){
      double extraX = (w*0.5-margin)*p;
      color fillColor = codon.getColor(p);
      fill(0);
      dRect(extraX+margin,appY+margin,appW,appCodonHeight-margin*2);
      if(codon.hasSubstance()){
        fill(fillColor);
        double trueW = appW*codon.codonHealth;
        double trueX = extraX+margin;
        if(p == 0){
          trueX += appW*(1-codon.codonHealth);
        }
        dRect(trueX,appY+margin,trueW,appCodonHeight-margin*2);
      }
      fill(255);
      dText(codon.getText(p),extraX+w*0.25,appY+appCodonHeight/2+11);
      
      if(p == codonToEdit[VirusInfo.Codon_Edit_Col] && i == codonToEdit[VirusInfo.Codon_Edit_Row]){
        double highlightFac = 0.5+0.5*sin(frameCount*0.25);
        fill(255,255,255,(float)(highlightFac*140));
        dRect(extraX+margin,appY+margin,appW,appCodonHeight-margin*2);
      }
    }
  }
  if(selectedCell == UGOcell){
    fill(255);
    textFont(font,60);
    double avgY = (h+height-y)/2;
    dText("( - )",w*0.25,avgY+11);
    dText("( + )",w*0.75-margin,avgY+11);
  }
  popMatrix();
}
void drawEditTable(double[] dims){
  double x = dims[0];
  double y = dims[1];
  double w = dims[2];
  double h = dims[3];
  
  double appW = w-margin*2;
  textFont(font,30);
  textAlign(CENTER);
  
  int p = codonToEdit[VirusInfo.Codon_Edit_Col];
  int s = codonToEdit[VirusInfo.Codon_Edit_RGL_Start];
  int e = codonToEdit[VirusInfo.Codon_Edit_RGL_End];
  if(p >= 0){
    pushMatrix();
    dTranslate(x,y);
    int choiceCount = VirusInfo.getOptionSize(codonToEdit[VirusInfo.Codon_Edit_Col]);
    double appChoiceHeight = h/choiceCount;
    for(int i = 0; i < choiceCount; i++){
      double appY = appChoiceHeight*i;
      color fillColor = VirusInfo.getColor(p,i);
      fill(fillColor);
      dRect(margin,appY+margin,appW,appChoiceHeight-margin*2);
      fill(255);
      dText(VirusInfo.getTextSimple(p, i, s, e),w*0.5,appY+appChoiceHeight/2+11);
    }
    popMatrix();
  }
}
void drawGenomeArrows(double dw, double dh){
  float w = (float)dw;
  float h = (float)dh;
  fill(255);
  beginShape();
  vertex(-5,0);
  vertex(-45,-40);
  vertex(-45,40);
  endShape(CLOSE);
  beginShape();
  vertex(w+5,0);
  vertex(w+45,-40);
  vertex(w+45,40);
  endShape(CLOSE);
  noStroke();
  rect(0,-h/2,w,h);
}
void dRect(double x, double y, double w, double h){
  noStroke();
  rect((float)x, (float)y, (float)w, (float)h);
}
void dText(String s, double x, double y){
  text(s, (float)x, (float)y);
}
void dTranslate(double x, double y){
  translate((float)x, (float)y);
}
void daLine(double[] a, double[] b){
  float x1 = (float)trueXtoAppX(a[0]);
  float y1 = (float)trueYtoAppY(a[1]);
  float x2 = (float)trueXtoAppX(b[0]);
  float y2 = (float)trueYtoAppY(b[1]);
  strokeWeight((float)(0.03*camS));
  line(x1,y1,x2,y2);
}
void drawBar(color col, double stat, String s, double y){
  fill(150);
  rect(25,(float)y,500,60);
  fill(col);
  rect(25,(float)y,(float)(stat*500),60);
  fill(0);
  textFont(font,48);
  textAlign(LEFT);
  text(s+": "+nf((float)(stat*100),0,1)+"%",35,(float)y+47);
}
void drawCells(){
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      cells[y][x].drawCell(trueXtoAppX(x),trueYtoAppY(y),trueStoAppS(1));
    }
  }
}
void produceUGO(double[] coor){
  if(getCellAt(coor,false) != null && getCellAt(coor,false).cellType == VirusInfo.cell_type_none){
    String genomeString = UGOcell.genome.getGenomeString();
    Particle newUGO = new Particle(coor,VirusInfo.particle_type_ugo,genomeString,frameCount);
    particles.get(VirusInfo.particle_type_ugo).add(newUGO);
    //newUGO.addToCellList();
    addToCellList(newUGO);
    lastEditTimeStamp = frameCount;
  }
}
public void moveDim(Particle p, int d)
{
  float visc = (getCellTypeAt(p.getPos(),true) == 0) ? 1 : 0.5;//getCellTypeAt(p.coor,true)
  double[] future = p.copyCoor();
  future[d] = p.getPos(d)+p.getVel(d)*visc*PLAY_SPEED;
  if(cellTransfer(p.getPos(), future)){//cellTransfer(p.coor, future)
    int currentType = getCellTypeAt(p.getPos(),true);//getCellTypeAt(p.coor,true)
    Cell futureCell = getCellAt(future,true);
    int futureType = futureCell.cellType;//getCellTypeAt(future,true);
    if(p.particleType == VirusInfo.particle_type_ugo && currentType == VirusInfo.cell_type_none && futureType == VirusInfo.cell_type_cell && p.particleCodonCount()+getCellAt(future,true).getGenomeLength() <= MAX_CODON_COUNT)
    { // there are few enough codons that we can fit in the new material!
      injectGeneticMaterial(p, future);  // UGO is going to inject material into a cell!
    }
    else if(futureType == VirusInfo.cell_type_wall || (p.particleType >= VirusInfo.particle_type_waste && (currentType != VirusInfo.cell_type_none || futureType != VirusInfo.cell_type_none)))
    { // bounce
      Cell b_cell = getCellAt(future,true);
      if(b_cell.cellType >= VirusInfo.cell_type_cell)
      {
        b_cell.hurtWall(1, p.particleType, p.particleCodonCount());//PARTICLES ARE BAD
      }
      if(p.getVel(d) >= 0)
      {
        p.setVel(d, -Math.abs(p.getVel(d)));
        future[d] = (float)Math.ceil(p.getPos(d))-EPS;
      }else
      {
        p.setVel(d, Math.abs(p.getVel(d)));
        future[d] = (float)Math.floor(p.getPos(d))+EPS;
      }
      Cell t_cell = getCellAt(p.getPos(),true);//getCellAt(p.coor,true)
      if(t_cell.cellType >= VirusInfo.cell_type_cell)
      {
        t_cell.hurtWall(1, p.particleType, p.particleCodonCount());//PARTICLES ARE BAD
      }
    }
    else
    {
      while(future[d] >= WORLD_SIZE)
      {
        future[d] -= WORLD_SIZE;
      }
      while(future[d] < 0)
      {
        future[d] += WORLD_SIZE;
      }
      hurtWalls(p, p.getPos(), future);//hurtWalls(p, p.coor, future)
      if(futureType == VirusInfo.cell_type_cell)//need to rewrite pos to use VECTORS!
      {
        //move particle into cell
        //futureCell.addParticleToCell(p);
        //particles.remove(p);
      }
    }
  }
  p.setPos(future);//p.coor = future
}
public void injectGeneticMaterial(Particle p, double[] futureCoor){
  Cell c = getCellAt(futureCoor,true);
  int injectionLocation = c.rotateOn;//c.genome.rotateOn;
  ArrayList<Codon> toInject = p.UGO_genome.getCodons();
  int INJECT_SIZE = p.particleCodonCount();
  
  for(int i = 0; i < toInject.size(); i++){
    int[] info = toInject.get(i).codonInfo;
    c.genome.addCodon(injectionLocation+i,new Codon(info,1.0));
  }
  if(c.performerOn >= c.rotateOn){
    c.performerOn += INJECT_SIZE;
  }
  c.rotateOn += INJECT_SIZE;
  tamper(c);
  removeParticle(p);
  //Should UGO injection create a waste particle?
  //Particle newWaste = new Particle(coor,particle_type_waste,-99999);
  //newWaste.addToCellList();
  //particles.get(1).add(newWaste);
}
public void hurtWalls(Particle p, double[] coor, double[] future){
  Cell p_cell = getCellAt(coor,true);
  if(p_cell.cellType >= VirusInfo.cell_type_cell){
    p_cell.hurtWall(1);//PARTICLES ARE BAD
  }
  p_cell.removeParticleFromCell(p);
  Cell n_cell = getCellAt(future,true);
  if(n_cell.cellType >= VirusInfo.cell_type_cell){
    n_cell.hurtWall(1);//PARTICLES ARE BAD
  }
  n_cell.addParticleToCell(p);
}
public void iterateParticle(Particle p){
  for(int dim = 0; dim < 2; dim++){
    moveDim(p, dim);
  }
}
public void removeParticle(Particle p){
  particles.get(p.particleType).remove(p);
  getCellAt(p.getPos(),true).particlesInCell.get(p.particleType).remove(p);//getCellAt(p.coor,true).particlesInCell.get(p.particleType).remove(p)
}
public void addToCellList(Particle p){
  Cell cellIn = getCellAt(p.getPos(),true);//getCellAt(p.coor,true)
  cellIn.addParticleToCell(p);
}
void doParticleCountControl(){
  ArrayList<Particle> foods = particles.get(VirusInfo.particle_type_food);
  while(foods.size() < foodLimit){
    int choiceX = -1;
    int choiceY = -1;
    while(choiceX == -1 || cells[choiceY][choiceX].cellType >= VirusInfo.cell_type_wall){
      choiceX = (int)random(0,WORLD_SIZE);
      choiceY = (int)random(0,WORLD_SIZE);
    }
    double extraX = random(0.3,0.7);
    double extraY = random(0.3,0.7);
    double x = choiceX+extraX;
    double y = choiceY+extraY;
    double[] coor = {x,y};
    Particle newFood = new Particle(coor,VirusInfo.particle_type_food,frameCount);
    foods.add(newFood);
    //newFood.addToCellList();
    addToCellList(newFood);
  }
  
  ArrayList<Particle> wastes = particles.get(VirusInfo.particle_type_waste);
  if(wastes.size() > foodLimit){
    removeWasteTimer -= (wastes.size()-foodLimit)*REMOVE_WASTE_SPEED_MULTI;
    if(removeWasteTimer < 0){
      int choiceIndex = -1;
      int iter = 0;
      while(iter < 50 && (choiceIndex == -1 || getCellAt(wastes.get(choiceIndex).getPos(),true).cellType == VirusInfo.cell_type_cell)){//getCellAt(wastes.get(choiceIndex).coor,true).cellType
        choiceIndex = (int)(Math.random()*wastes.size());
      } // If possible, choose a particle that is NOT in a cell at the moment.
      //wastes.get(choiceIndex).removeParticle();
      removeParticle(wastes.get(choiceIndex));
      removeWasteTimer++;
    }
  }
}
public void tamper(Cell c){
  if(!c.tampered){
    c.tampered = true;
    cellCounts[0]--;
    cellCounts[1]++;
  }
}