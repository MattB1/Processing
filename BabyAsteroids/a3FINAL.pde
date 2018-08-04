/********************************************************************************
* File: a3.pde
* Group: Aiden Toms, Matt Bubb, Steph Cooper (Group 36)
* Date: --/05/2018
* Course: COSC101 - Software Development Studio 1
* Desc: A remake of "Asteroids", the popular arcade game released by Atari in 1979.
* Usage: Make sure to run in the processing environment and press play etc.
* Notes: 
* // Comment on sound - doesn't work on some systems?
* Music credits:
* gameMusic = ...
* titleMusic = "Light Years" by Eric Matyas www.soundimage.org
* Sound effects credits:
* collisionSound = "362421__alphatrooper18__laser-shoot1" by alphatrooper18
*                   https://freesound.org
* shotSound = "retro explosion sfx" by stumpbutt https://freesound.org
* explosionSound = "Explosion1" by Eric Matyas www.soundimage.org
********************************************************************************/

import processing.sound.*; 

PShape ship;
PShape shot;
PShape astroBig;
PShape astroMed;
PShape astroSml;
PShape heart;
PImage[] explosionGIF;

ArrayList<PVector> asteroids;
ArrayList<PVector> astroDir;
ArrayList<PShape> astroImg;
ArrayList<PVector> shots;
ArrayList<PVector> sDirections;

int astroNums = 1;  // number of asteroids to start with
int collisionTime;  // keeps track of the time when collision occurred  
int explosionTime; // keeps track of the time when explosion occurred 
int exIndex = 0;  // To keep track of index in explosionGIF array
int score = 0;
int startLevelScore;
int currentLevel;
int level = 1;
int lives = 3;
int gameState = 1;

float speed = 0;  // rename? 
float maxSpeed = 4;
float radians=radians(270);  
float explosionStrength = 1;

PVector shipCoord;
PVector shipDirection;
PVector shipAcceleration;
PVector shipVelocity;
PVector expLoc;

boolean alive = true;
boolean collisionImmune = false; 
boolean exploding = false;
boolean levelling = false;
boolean sUP=false, sDOWN=false, sRIGHT=false, sLEFT=false;

// Music flags ensure the music isn't played during every run of draw()
boolean gameMusicFlag = false; 
boolean musicFlag = false;
boolean musicFlag2 = false;
boolean explosionSoundFlag = false;
boolean saveFlag = false;
boolean sortFlag = true;

JSONArray highScores;
int[] scoreArray;

SoundFile collisionSound;
SoundFile explosionSound;
SoundFile shotSound;
SoundFile titleMusic;
SoundFile gameMusic;


void setup() {
  size(800, 800); 
  // Initialise PVectors 
  shipCoord = new PVector(width/2, height/2);
  shipDirection = new PVector(0, 0);
  shipAcceleration = new PVector();
  shipVelocity = new PVector();
  // Create ship
  ship = createShape();
  ship.beginShape();
  ship.fill(255);
  ship.noFill();
  ship.vertex(0, -20);
  ship.vertex(20, 20);
  ship.vertex(-20, 20);
  endShape(CLOSE);  
  // Create shots
  stroke(245, 242, 151);
  strokeWeight(3);
  shot = createShape(POINT, 0, 0);  
  // Create big asteroid
  astroBig = createShape();
  astroBig.beginShape();
  astroBig.stroke(255);
  astroBig.strokeWeight(1);
  astroBig.noFill();
  astroBig.vertex(-46, -20);
  astroBig.vertex(-26, -40);
  astroBig.vertex(-4, -30);
  astroBig.vertex(24, -40);
  astroBig.vertex(44, -20);
  astroBig.vertex(24, -10);
  astroBig.vertex(46, 10);
  astroBig.vertex(24, 40);
  astroBig.vertex(-6, 30);
  astroBig.vertex(-26, 40);
  astroBig.vertex(-46, 24);
  astroBig.vertex(-36, -6);
  astroBig.vertex(-46, -20);
  endShape(CLOSE);
  // Create medium asteroid
  astroMed = createShape();
  astroMed.beginShape();
  astroMed.stroke(255);
  astroMed.strokeWeight(1);
  astroMed.noFill();
  astroMed.vertex(-30, -12);
  astroMed.vertex(-16, -26);
  astroMed.vertex(-2, -22);
  astroMed.vertex(18, -26);
  astroMed.vertex(30, -16);
  astroMed.vertex(24, -2);
  astroMed.vertex(30, 8);
  astroMed.vertex(8, 26);
  astroMed.vertex(-20, 22);
  astroMed.vertex(-30, 8);
  astroMed.vertex(-30, -12);
  endShape(CLOSE);  
  // Create small asteroid
  astroSml = createShape();
  astroSml.beginShape();
  astroSml.stroke(255);
  astroSml.strokeWeight(1);
  astroSml.noFill();
  astroSml.vertex(-15, -7);
  astroSml.vertex(-9, -13);
  astroSml.vertex(1, -9);
  astroSml.vertex(7, -13);
  astroSml.vertex(15, -7);
  astroSml.vertex(7, -3);
  astroSml.vertex(15, 3);
  astroSml.vertex(7, 13);
  astroSml.vertex(-3, 9);
  astroSml.vertex(-9, 13);
  astroSml.vertex(-15, 7);
  astroSml.vertex(-15, -7);
  endShape(CLOSE);
  // Create heart
  heart = createShape();
  heart.beginShape();
  heart.noStroke();
  heart.fill(200, 0, 0);
  heart.vertex(0, -5);
  heart.vertex(-5, -10);
  heart.vertex(-10, -5);
  heart.vertex(0, 10);
  heart.vertex(10, -5);
  heart.vertex(5, -10);
  endShape(CLOSE);
  // Initalise Asteroids & initialise/reset shots
  initialiseAsteroids();
  initialiseShots();
  // Load sounds
  collisionSound = new SoundFile(this, "collisionSound.mp3");
  explosionSound = new SoundFile(this, "explosion1.wav");
  shotSound = new SoundFile(this, "shotSound.wav");
  gameMusic = new SoundFile(this, "Pulse.mp3");
  titleMusic = new SoundFile(this, "LightYears.mp3");
  // Load explosion images into array
  explosionGIF = new PImage[13];
  for (int i = 0; i<explosionGIF.length; i++) {
    explosionGIF[i] = loadImage("data/explosionGif/"+i+".gif");
  }
  
  highScores = loadJSONArray("data/scores.json");
  scoreArray = new int[5];
  for (int i = 0; i < highScores.size(); i++) {
    JSONObject userScore = highScores.getJSONObject(i);
    scoreArray[i] = userScore.getInt("score");
  }
}


void draw() {
  if (gameState == 1)
    startScreen();   
 
  if (gameState == 2) {
    background(0);
    if(gameMusicFlag == false) {
        gameMusic.loop();
      gameMusicFlag = true;
    }
    //might be worth checking to see if you are still alive first
    if (alive) {
      moveShip();
      collisionDetection();
      if (exploding && lives < 3)
        drawExplosion();
      if (!collisionImmune)
        drawShots();
      drawAsteroids();
      displayHUD();
      immunityCheck();
      if(asteroids.size() == 0)
        levelUp();  
    }  
    if (!alive) {
      if (sortFlag) {
        sortScore();
        if (saveFlag)
          saveScore();
      }
    gameOver(); 
    }
  }
}


/*******************************************************************************
 * Function: moveShip() 
 * Parameters: None
 * Returns: Void
 * Desc: Draws, rotates and moves the ship around the screen. 
*******************************************************************************/
void moveShip() {
  //this function should update if keys are pressed down 
  // - this creates smooth movement
  //update rotation,speed and update current location
  //you should also check to make sure your ship is not outside of the window
  ship.resetMatrix();
  ship.rotate(radians(shipDirection.x));
  shape(ship, shipCoord.x, shipCoord.y);
  shipAcceleration.x = 0;
  shipAcceleration.y = 0;
  
  if (sUP) {
    shipAcceleration.x = 0.5 * cos(radians(shipDirection.x) - PI/2);
    shipAcceleration.y = 0.5 * sin(radians(shipDirection.x) - PI/2);
    
  }
  if (sDOWN) {
    shipAcceleration.x -= 0.2 *cos(radians(shipDirection.x) - PI/2);
    shipAcceleration.y -=0.2 *sin(radians(shipDirection.x) - PI/2) ;
  }
  if (sRIGHT)
    shipDirection.x += 5;
  if (sLEFT)
    shipDirection.x -= 5;
    
  shipVelocity.add(shipAcceleration);
  shipCoord.add(shipVelocity);
  shipVelocity.mult(0.96);
  shipCoord.x %= width;
  
  if (shipCoord.x < -10)
    shipCoord.x = width;
  shipCoord.y %= height;
  if (shipCoord.y < -10)
    shipCoord.y = height;
}


/*******************************************************************************
 * Function: drawShots() 
 * Parameters: None
 * Returns: Void
 * Desc: Draws and moves shots around the screen. This function deletes shots
         if they reach the bounds of the window, removing the possibility of a
         shot being drawn infinitely.
*******************************************************************************/
void drawShots() {
  if (shots.size() > 0) {
    for (int i = 0; i < shots.size(); i++) {
      shape(shot, shots.get(i).x, shots.get(i).y);  
      shots.get(i).add(sDirections.get(i));
      //delete shot if out of bounds
      if (shots.get(i).x < 0 || shots.get(i).x > width || 
          shots.get(i).y < 0 || shots.get(i).y > height) {
        shots.remove(i); 
        sDirections.remove(i);
      }
    }
  }
}


/*******************************************************************************
 * Function: initialiseAsteroids() 
 * Parameters: None
 * Returns: Void
 * Desc: Initilises positions, directions and shapes for each asteroid drawn
         at the beginning of each level.
*******************************************************************************/
void initialiseAsteroids() {
  // initialise asteroid positions and directions;
  asteroids = new ArrayList<PVector>();
  astroDir = new ArrayList<PVector>();
  astroImg = new ArrayList<PShape>();
  for (int i = 0; i <astroNums; i++) {
    PVector asteroidLoc = new PVector(random(astroBig.width, 
                                             width - astroBig.width), 
                                      random(astroBig.height,
                                             height - astroBig.height));
    asteroids.add(asteroidLoc);
    // set the random directions of each asteroid
    PVector asteroidDir = new PVector(random(-1.0, 1.0), random(-1.0, 1.0));
    astroDir.add(asteroidDir);
    astroImg.add(astroBig);
  }
}


/**************************************************************
 * Function: drawAsteroids() 
 * Parameters: None
 * Returns: Void
 * Desc: Draws asteroids to the screen.
 ***************************************************************/
void drawAsteroids() {
  if (asteroids.size() > 0) {
    for (int i = 0; i < asteroids.size(); i++) {
      shape(astroImg.get(i), asteroids.get(i).x,
            asteroids.get(i).y);
      asteroids.get(i).add(astroDir.get(i));
      if (asteroids.get(i).x < astroImg.get(i).width || 
          asteroids.get(i).x > width - astroImg.get(i).width)
        astroDir.get(i).x *= -1;
      if (asteroids.get(i).y < astroImg.get(i).height ||
          asteroids.get(i).y > height - astroImg.get(i).height)
        astroDir.get(i).y *= -1;
    }
  }
}


/*******************************************************************************
 * Function: collisionDetection() 
 * Parameters: None
 * Returns: Void
 * Desc: Checks if ship has collided with an asteroid or if a shot has collided
         with an asteroid then handles accordingly.
*******************************************************************************/
void collisionDetection() {
  //check if ship has collided with asteroids
  if(!collisionImmune) {
    for(int i = 0; i <asteroids.size(); i++) {
      if (dist(shipCoord.x, shipCoord.y, asteroids.get(i).x, asteroids.get(i).y)
          < ship.width + astroImg.get(i).width) {
          explosionSound.play();
        // explosion   
        exploding = true;
        expLoc = shipCoord.copy();        
        lives--;
        collisionImmune = true; // immune to collision for a certain time
        collisionTime = millis();        
        initialiseShots();
        
        shipAcceleration.x = 0;
        shipAcceleration.y = 0;
        shipVelocity.x = 0;
        shipVelocity.y = 0;      
        shipCoord.x = width/2;
        shipCoord.y = height/2; 
        
        if (lives == 0)
          alive = false;
      }  
    }
  }
  
  // Check if shots have collided with asteroids
  for (int i = 0; i < shots.size(); i++) {
    for (int j = 0; j < asteroids.size(); j++) {
      if (dist(shots.get(i).x, shots.get(i).y, asteroids.get(j).x, 
          asteroids.get(j).y) < astroImg.get(j).width) {
        collisionSound.play();
        astroMultiply(j);
        score++;
        asteroids.remove(j);
        astroDir.remove(j);
        astroImg.remove(j);
        shots.remove(i);
        sDirections.remove(i);
        break;
      }     
    }   
  } 
}


/*******************************************************************************
 * Function: initialiseShots() 
 * Parameters: None
 * Returns: Void
 * Desc: Resets the shots and sDirections arrayLists so shots that were still on
         the screen at time of level up/loss of life are not drawn after
         immunityCheck().
*******************************************************************************/
void initialiseShots() {
  shots = new ArrayList<PVector>();
  sDirections = new ArrayList<PVector>();
}


/*******************************************************************************
 * Function: astroMultiply(int ind) 
 * Parameters: int ind - the index of the asteroid and astroImg that got hit.
 * Returns: Void
 * Desc: Adds asteroids and asteroid images to the asteroids and astroImg
         arrayLists rspectively, if the asteroid that got hit wasn't already the
         smallest type.
*******************************************************************************/
void astroMultiply(int ind) {
  if (astroImg.get(ind) != astroSml) {
    for (int k = 0; k < 3; k++) {
      PVector newDir = new PVector(random(-1.0, 1.0), random(-1.0, 1.0));
      asteroids.add(asteroids.get(ind).copy());
      astroDir.add(newDir);
      if (astroImg.get(ind) == astroBig)
        astroImg.add(astroMed);
      if (astroImg.get(ind) == astroMed)
        astroImg.add(astroSml);
    }
  }
}  


/*******************************************************************************
 * Function: keyPressed() 
 * Parameters: None
 * Returns: Void
 * Desc: Modifies booleans for moveShip() based on which key/s is/are pressed.
*******************************************************************************/
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP)
      sUP=true;
    if (keyCode == DOWN)
      sDOWN=true;
    if (keyCode == RIGHT)
      sRIGHT=true;
    if (keyCode == LEFT)
      sLEFT=true;
  }
}


/*******************************************************************************
 * Function: keyReleased() 
 * Parameters: None
 * Returns: Void
 * Desc: Modifies booleans for moveShip based on which key/s has/have been
         released.
         Also adds shot locations and directions when the space bar has been
         released. This has been allotted to keyReleased() to add one shot per 
         press of the space bar, rather than an infinite stream of shots that 
         resulted from keyPressed().
*******************************************************************************/
void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP)
      sUP=false;
    if (keyCode == DOWN)
      sDOWN=false;
    if (keyCode == RIGHT)
      sRIGHT=false;
    if (keyCode == LEFT)
      sLEFT=false;
  } else if (key == ' ' && !collisionImmune) {
    PVector shotDir = new PVector();
    shots.add(shipCoord.copy());
    shotDir.x = 20 * cos(radians(shipDirection.x) - PI/2);
    shotDir.y = 20 * sin(radians(shipDirection.x) - PI/2);
    sDirections.add(shotDir);
    shotSound.play();
  }
}


/*******************************************************************************
 * Function: gameOver() 
 * Parameters: None
 * Returns: Void
 * Desc: Game over screen. Displays high scores and adds options to 'continue'
         or start 'new game'.
*******************************************************************************/
void gameOver() {
  if (musicFlag2 == false) {
    titleMusic.play();
    musicFlag2 = true;
  }  
  background(0);  
  //Game Over text
  String s = "Game Over";
  fill(255);
  textSize(90);
  textAlign(CENTER);
  text(s, width/2,height/2-200);
  
  String hs = "High Scores";
  textSize(50);
  textAlign(CENTER, CENTER);
  text(hs, width/2, height/2 - 150);
  
  textSize(30);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < scoreArray.length; i++) { 
    text(scoreArray[i], width/2, (height/2 - 95) + i * 50);
  }
  
  //continue button
  stroke(255);
  noFill();
  rectMode(CENTER);
  rect(width/2,height/2+200, 400,100);
  textSize(50);
  String s4 = "CONTINUE";
  textAlign(CENTER);
  text(s4, width/2, height/2+220);
  if(mouseX>= width/2-200 && mouseX<= width/2+200 &&
     mouseY>=height/2+150 && mouseY<=height/2+250){
    String warning = "WARNING: high scores from a continued game will not be saved";
    textSize(20);
    fill(200, 0, 0);
    textAlign(CENTER);
    text(warning, mouseX, mouseY);
    
    if (mousePressed) {
    titleMusic.stop();
    continueGame();
    }
  }
  //new game button
  stroke(255);
  noFill();
  rectMode(CENTER);
  rect(width/2,height/2+300, 400,100);
  fill(255);
  textSize(50);
  String s3 = "NEW GAME";
  textAlign(CENTER);
  text(s3, width/2, height/2+320);
  if(mousePressed && mouseX>= width/2-200 && mouseX<= width/2+200 &&
     mouseY>=height/2+250 && mouseY<=height/2+350){
     titleMusic.stop();
    newGame();
  } 
}


/*******************************************************************************
 * Function: newGame() 
 * Parameters: None
 * Returns: Void
 * Desc: Starts game from start screen or restarts game from game over screen.  
*******************************************************************************/
void newGame(){
// start/restart game
   collisionTime = millis();
   collisionImmune = true;
   sortFlag = true;
   level = 1;
   score = 0;
   lives = 3;
   astroNums = 1;
   alive = true;
   initialiseShots();
   initialiseAsteroids();
}


/*******************************************************************************
 * Function: continueGame() 
 * Parameters: None
 * Returns: Void
 * Desc: Continues game from game over screen. Score and lives are reset. 
         Ability to get a high score and keep it on the score board is removed
         for the duration of the continued game.
*******************************************************************************/
void continueGame(){
  collisionTime = millis();
  collisionImmune = true;
  sortFlag = false;
  score = 0;
  lives = 3;
  alive = true;
  level = currentLevel;
  initialiseShots();
  initialiseAsteroids();
}


/*******************************************************************************
 * Function: displayHUD() 
 * Parameters: None
 * Returns: Void
 * Desc: Displays the score, level and remaining lives for the current game.
*******************************************************************************/
void displayHUD(){
    fill(255);
    textFont(createFont("FreeMono bold", 30));
    text("Score: " + score, 180, 40);
    text("Level: " + level, width-70, 40);
    for (int i = 0; i < lives; i++)
      shape(heart, (30 + i * 30), 30);
}


/*******************************************************************************
 * Function: immunityCheck() 
 * Parameters: None
 * Returns: Void
 * Desc: Checks if the ship is meant to be immune at the time. If so, the ship's
         fill is changed to a translucent red to represent immunity at the time.
         This function and related immunity values were implemented to avoid a
         ship being destroyed at the start of a level by an asteroid that
         spawned within the collision radius.
*******************************************************************************/
void immunityCheck() {
  if(collisionImmune) {
    ship.fill(201,41,41);
    if(levelling == true) {
      text("LEVEL " + level, width/2, height/2 -200);
    }
  }
  
  if(millis() > collisionTime + 3000) {
    collisionImmune = false;
    ship.fill(255);
    levelling = false;
  }
}


/*******************************************************************************
 * Function: startScreen() 
 * Parameters: None
 * Returns: Void
 * Desc: Displays the start screen, which includes the game title, high scores,
         play button and creators.
*******************************************************************************/
void startScreen(){
  if (musicFlag == false){
    titleMusic.play();
    musicFlag = true;
  }
  background(0);
  //Game Over text
  String s = "ASTEROIDS";
  fill(255);
  textSize(100);
  textAlign(CENTER);
  text(s, width/2,height/2-200);
  //Play Again text
  String hs = "High Scores";
  textSize(50);
  textAlign(CENTER, CENTER);
  text(hs, width/2, height/2 - 150);
  
  textSize(30);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < scoreArray.length; i++) { 
    text(scoreArray[i], width/2, (height/2 - 95) + i * 50);
  }
  //Play button
  stroke(255);
  noFill();
  rectMode(CENTER);
  rect(width/2,height/2+200, 400,100);
  textSize(50);
  String s3 = "PLAY";
  textAlign(CENTER);
  text(s3, width/2, height/2+220);
  if(mousePressed == true && mouseX>= width/2-200 && mouseX<= width/2+200 && mouseY>=height/2+150 && mouseY<=height/2+250){
    newGame();
    gameState = 2;
    titleMusic.stop();
  }
  String creators = "by Aiden, Matt & Steph";
  textSize(20);
  text(creators, width/2, height -80);  
}


/*******************************************************************************
 * Function: levelUp() 
 * Parameters: None
 * Returns: Void
 * Desc: Called when all asteroids for a given level are destroyed.
         Reinitialises shots, increments level and number of asteroids to be
         initialised before reinitialising asteroids, resets ship position and
         makes the ship immune for 3 seconds.
*******************************************************************************/
void levelUp(){
  levelling = true;
  // New game, keep score, replenish lives, add one more asteroid
  startLevelScore = score;
  currentLevel = level+1;
  // Add another asteroid
  astroNums += 1;
  //lives = 3;
  alive = true;
  initialiseShots();
  initialiseAsteroids();  
  // Make ship immune for 3 seconds
  collisionImmune = true; // immune to collision for a certain time
  collisionTime = millis(); 
  // Reset ship
  shipAcceleration.x = 0;
  shipAcceleration.y = 0;
  shipVelocity.x = 0;
  shipVelocity.y = 0;      
  shipCoord.x = width/2;
  shipCoord.y = height/2;
  // Update level
  level +=1;
  
}


/*******************************************************************************
 * Function: drawExplosion() 
 * Parameters: None
 * Returns: Void
 * Desc: Draws the explosion animation at the location where the ship was hit.
*******************************************************************************/
void drawExplosion() {
 //   explosionTime = millis();
    // Step through each index in explosionGIF array
  if (exIndex<12)
    image(explosionGIF[exIndex], expLoc.x-125, expLoc.y-125);
    
  // Control speed of explosion by changing frameCount (higher = slower)
  if (frameCount%4 == 0) {
    exIndex++;
    // Loop explosion
    if (exIndex == 13) {
      exIndex = 0;
    }
  }
 
  explosionStrength +=5;
  if (explosionStrength > 100) {
    exploding = false;
    explosionStrength = 1;
  }  
}


/*******************************************************************************
 * Function: sortScore()
 * Parameters: None
 * Returns: Void
 * Desc: At death, if user's score is higher than a high score, adds score to
         high scores and shifts remaining scores down 1 place, removing the
         previous lowest score.
*******************************************************************************/
void sortScore() {
  int[] copy = new int[scoreArray.length];
  for (int i = 0; i < scoreArray.length; i++)
    copy[i] = scoreArray[i];
  for (int i = 0; i < scoreArray.length; i++) {
    if (score > scoreArray[i]) {
      saveFlag = true;
      scoreArray[i] = score;
      int count = i++;
      for (int j = i; j < scoreArray.length; j++) {
        scoreArray[j] = copy[count];
        count++;
      }
      score = 0;
    }
  }
}


/*******************************************************************************
 * Function: saveScore()
 * Parameters: None
 * Returns: Void
 * Desc: If current game's score qualified as a high score, saves the new high
         scores to the data/scores.json file.
*******************************************************************************/
void saveScore() {
  for (int i = 0; i < scoreArray.length; i++) {
    JSONObject newScore = new JSONObject();
    newScore.setInt("score", scoreArray[i]);
    highScores.setJSONObject(i, newScore);
  }
  saveJSONArray(highScores, "data/scores.json");
  saveFlag = false;
}