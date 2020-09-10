double trueXtoAppX(double x){
  return (x-camX)*camS;//x*camS;//
}
double trueYtoAppY(double y){
  return (y-camY)*camS;//y*camS;//
}
double appXtoTrueX(double x){
  return x/camS+camX;//x/camS;//
}
double appYtoTrueY(double y){
  return y/camS+camY;//y/camS;//
}
double trueStoAppS(double s){
  return s*camS;
}
int getCellTypeAt(double x, double y, boolean allowLoop){
  int ix = (int)x;
  int iy = (int)y;
  if(allowLoop){
    ix = (ix+WORLD_SIZE)%WORLD_SIZE;
    iy = (iy+WORLD_SIZE)%WORLD_SIZE;
  }else{
    if(ix < 0 || ix >= WORLD_SIZE || iy < 0 || iy >= WORLD_SIZE){
      return 0;
    }
  }
  return cells[iy][ix].cellType;
}
int getCellTypeAt(double[] coor, boolean allowLoop){
  return getCellTypeAt(coor[0],coor[1],allowLoop);
}
Cell getCellAt(double x, double y, boolean allowLoop){
  int ix = (int)x;
  int iy = (int)y;
  if(allowLoop){
    ix = (ix+WORLD_SIZE)%WORLD_SIZE;
    iy = (iy+WORLD_SIZE)%WORLD_SIZE;
  }else{
    if(ix < 0 || ix >= WORLD_SIZE || iy < 0 || iy >= WORLD_SIZE){
      return null;
    }
  }
  return cells[iy][ix];
}
Cell getCellAt(double[] coor, boolean allowLoop){
  return getCellAt(coor[0],coor[1],allowLoop);
}
boolean cellTransfer(double x1, double y1, double x2, double y2){
  int ix1 = (int)Math.floor(x1);
  int iy1 = (int)Math.floor(y1);
  int ix2 = (int)Math.floor(x2);
  int iy2 = (int)Math.floor(y2);
  return (ix1 != ix2 || iy1 != iy2);
}
boolean cellTransfer(double[] coor1, double[] coor2){
  return cellTransfer(coor1[0], coor1[1], coor2[0], coor2[1]);
}
String framesToTime(double f){
  double ticks = f/GENE_TICK_TIME;
  String timeStr = nf((float)ticks,0,1);
  if(ticks >= 1000){
    timeStr = (int)(Math.round(ticks))+"";
  }
  return timeStr+"t since";
}
double euclidLength(double[] coor){
  return Math.sqrt(Math.pow(coor[0]-coor[2],2)+Math.pow(coor[1]-coor[3],2));
}
int loopCodonInfo(int val){
  while(val < -30){
    val += 61;
  }
  while(val > 30){
    val -= 61;
  }
  return val;
}
int getTypeFromXY(int preX, int preY){
  int[] weirdo = {0,1,1,2};
  int x = (preX/4)*3;
  x += weirdo[preX%4];
  int y = (preY/4)*3;
  y += weirdo[preY%4];
  int result = 0;
  for(int i = 1; i < WORLD_SIZE; i *= 3){
    if((x/i)%3 == 1 && (y/i)%3 == 1){
      result = 1;
      int xPart = x%i;
      int yPart = y%i;
      boolean left = (xPart == 0);
      boolean right = (xPart == i-1);
      boolean top = (yPart == 0);
      boolean bottom = (yPart == i-1);
      if(left || right || top || bottom){
        result = 2;
      }
    }
  }
  return result;
}