/**************************************************************
* File(s): Ass2.pde, fly.png,flybye,png,swatted.png,swatter,png,flies.wav
* splat.wav, Seravek-Bold-40.vlw
* Name: Matthew Bubb
* Date: 31/03/2018
* Course: COSC101 - Software Development Studio 1
* Desc: A giant fly swatter to fend off alien invaders.
* Usage: Make sure to run in the processing environment and press play.
*        The processing sound library may need to be downloaded to play sounds.
* Notes: flies.wav, splat.wav source http://www.freesounds.org, accessed: 31/03/2018
*        

**************************************************************/

import processing.sound.*;
SoundFile splat;
SoundFile flies;
PImage fly,flybye,swatter,swatted;
float[] fX,fY;  // fly locations array
float[] swat;  // fly swatted binary boolean array, 1 = swatted, 0 = not swatted
int score=0;  // increments when swatted.
boolean doOnce;

void setup(){
  size(800,400);
  fX=new float[0];
  fY=new float[0];
  swat=new float[0];
  // load images
  fly = loadImage("fly.png");
  flybye = loadImage("flybye.png");
  swatter =  loadImage("swatter.png");
  swatted = loadImage("swatted.png");  
  fX = append(fX, random(0,720)); //first fly - random location
  fY = append(fY, random(0,320));
  swat =append(swat,0); // used as a boolean and matches to each individual fly, 0 = fly not swatted, 1 = swatted.
  //sound
  splat = new SoundFile(this, "splat.wav");
  flies = new SoundFile(this, "fliesmono2.mp3");
  flies.loop();
}

void populate(){ // draw the flies in memory to the screen.
  for(int i=0;i<fX.length;i++){
    if(swat[i]==1){ // if swatted
      // resize the fly image and place based on fx/fy array values
      flybye.resize(80,0);
      image(flybye, fX[i], fY[i]);
    } else { // not swatted
      fly.resize(80,0);
      image(fly, fX[i], fY[i]);
    }
  }
}

void collisionDetect(){ //collision detection - detect collision between swatter and fly{
  for(int i=0; i<swat.length;i++){ // bounding box detection //<>//
    if(mouseX >= fX[i]-60 && mouseX <= fX[i]+60 && mouseY >= fY[i]-60 && mouseY<= fY[i]+60 && swat[i]==0)    
    { // condition should look at location of mouse and individual coordinates in fX and fY
      swat[i] = 1; // swatted
      fX = append(fX, random(0,720)); //new fly placed in random location when old fly dies.
      fY = append(fY, random(0,320));
      swat = append(swat,0); // new fly not swatted
      splat.play();
      score++;//increment score
    }     
  }
}      


void draw(){ 
  background(7,129,247);
  grass();
  sun();
  populate(); // draw flys to screen.
  fill(0);
  // load, set text size and location for score
  PFont scoreFont; 
  scoreFont = loadFont("Seravek-Bold-40.vlw");
  textFont(scoreFont);
  text("score:" + str(score), 20, 40);
  if(mousePressed && doOnce == false){ // image swap
    collisionDetect();
    int x = swatter.width;
    image(swatted, mouseX-x/2, mouseY-20);  //draw swatter image to around mouse locaiton - might want to play with this to get it to look right.
    doOnce = true;
    
    }else{
    int x = swatter.width;    
    image(swatter, mouseX-x/2, mouseY-20); // if not pressed then alternative image.    
  }
}
 
void mouseReleased(){
   doOnce = false;
}

void grass(){
    strokeWeight(4);
    stroke(0,255,0);
    for(int x=0;x<width;x++){ 
      line(x,height,x,height-40);
    }
}    
    
void sun(){
    fill(250,217,48);
    stroke(250,234,48);
    ellipse(width,25,150,150);
}
 