/**
listing-files taken from http://wiki.processing.org/index.php?title=Listing_files
@author antiplastik
*/

import processing.opengl.*;
class Photo{
  PImage img;
  float x;
  float y;
  float z;
  float smallWidth;
  float smallHeight;
  float currentWidth;
  float currentHeight;
  int id;
  boolean loading;
  public Photo(String url,float nx,float ny, int _id){
    img = requestImage(url);
    id = _id;
    loading = true;
    x = nx;
    y = ny;
    z = 0;
  }
  public void doneLoading(){
    loading = false;
    if(img.width > img.height){
      currentWidth = smallWidth = 120;
      currentHeight = smallHeight = img.height*(120/(float)img.width);
    }
    else{
      currentWidth = smallWidth = img.width*(120/(float)img.height);
      currentHeight = smallHeight = 120;
    }
  }
  public void drawImage(PGraphics g){
    g.translate(0,0,z);
    g.beginShape();
    g.texture(img);
    g.vertex(x*120 + (120-currentWidth)/2, y*120+(120-currentHeight)/2, 0, 0);
    g.vertex(x*120+currentWidth+(120-currentWidth)/2, y*120+(120-currentHeight)/2, 1, 0);
    g.vertex(x*120+currentWidth+(120-currentWidth)/2, y*120+currentHeight+(120-currentHeight)/2, 1, 1);
    g.vertex(x*120+(120-currentWidth)/2, y*120+currentHeight+(120-currentHeight)/2, 0, 1);
    
//    g.curveVertex(x*120 + (120-currentWidth)/2, y*120+(120-currentHeight)/2);
//    g.curveVertex(x*120+currentWidth+(120-currentWidth)/2, y*120+(120-currentHeight)/2);
//    g.curveVertex(x*120+currentWidth+(120-currentWidth)/2, y*120+currentHeight+(120-currentHeight)/2);
//    g.curveVertex(x*120+(120-currentWidth)/2, y*120+currentHeight+(120-currentHeight)/2);
    
    g.endShape();
    g.translate(0,0,-z);
  }
  public void drawBuffer(PGraphics b){
    b.translate(0,0,z);
    b.beginShape();
    b.noStroke();
    b.fill(-(id + 2));
    b.vertex(x*120 + (120-currentWidth)/2, y*120+(120-currentHeight)/2);
    b.vertex(x*120+currentWidth+(120-currentWidth)/2, y*120+(120-currentHeight)/2);
    b.vertex(x*120+currentWidth+(120-currentWidth)/2, y*120+currentHeight+(120-currentHeight)/2);
    b.vertex(x*120+(120-currentWidth)/2, y*120+currentHeight+(120-currentHeight)/2);
    b.endShape(CLOSE);
    b.translate(0,0,-z);
  }
}

Photo img;
int timer;
int nextimg = 0;
String[] filenames; 
ArrayList<PImage> images = new ArrayList<PImage>();
int visualMode = 1;
int NUMOFIMAGES = 100;
int FONTSIZE = 50;
PGraphics buffert;
XMLElement xml;
ArrayList photos;
boolean searching;
String searchString;
PFont font;
int worldWidth;
int worldHeight;
float worldX;
float worldY = 100;
float worldZ;
float focusX;
float focusY;
float destZ = 100;
float destY;
float destX;
float worldRotateX;
float worldRotateY;
float worldRotateDestX;
float worldRotateDestY;

void setup(){
  
  
// we'll have a look in the data folder (Change your own absolute path)
  java.io.File folder = new java.io.File(dataPath("/Users/villehenriksson/Documents/Koulu/Sisällöntuotannon projektityö/Python Materiaalit/Snapshots/VtmInsta/photoSample/"));
   
  // let's set a filter (which returns true if file's extension is .jpg)
  java.io.FilenameFilter jpgFilter = new java.io.FilenameFilter() {
   public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".jpg");
    }
  };
 
  // list the files in the data folder, passing the filter as parameter
  filenames = folder.list(jpgFilter);
   
  // get and display the number of jpg files
  println(filenames.length + " jpg files in specified directory");
   
  // display the filenames
  for (int i = 0; i < filenames.length; i++) {
    println(filenames[i]);

  }

  size(screen.width, screen.height, OPENGL);
  buffert = createGraphics(width,height,P3D);
  font = createFont("Arial",FONTSIZE);
  textSize(FONTSIZE);
  textAlign(CENTER,CENTER);
  photos = new ArrayList();
  searchString = new String();
  loadImagesFromFolder();
  imageMode(CENTER);
  textureMode(NORMALIZED);
  noStroke();
  smooth();
  worldZ = 100;
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      mouseWheel(evt.getWheelRotation());
    }
  }
  );
  
}

//images are drawn here
void draw() {

  //if UP-button is pressed, photos are drawn one by one
  if(visualMode == 1){
    
    buffert.beginDraw();
    buffert.background(color(255));
    buffert.endDraw();  
    frameRate(4);
    pushMatrix();
    background(0);
    Photo p = (Photo)photos.get(nextimg);
    nextimg=(nextimg+1)%filenames.length;
    println(nextimg);
    image(p.img,screen.width/2,screen.height/2);
    g.removeCache(p.img);
    popMatrix();

  }

//If DOWN-button is pressed, photowall will be drawn
  if(visualMode == 2){
  
  frameRate(60);
  println("Kuvaseina");
  pushMatrix();
  background(0);
  if(worldZ < 300){
    worldRotateDestX = ((PI/2)*mouseY/height-PI/4);
    worldRotateDestY = ((PI/2)*mouseX/width-PI/4);
    destY = (height-worldHeight)/2-60;
    destY += -(mouseY-height/2)/2;
  }
  else{
    worldRotateDestX = 0;
    worldRotateDestY = 0;
    destY = -(mouseY-height/2);
  }
  worldY += (destY-worldY)/max((worldZ-100),25);
  worldZ += (destZ-worldZ)/50;
  worldX -= (mouseX-width/2)/max((worldZ-50),25);
  worldX = min(max(worldX,-worldWidth+width/2),width);
  worldY = min(max(worldY,-worldHeight+height/2),height);
  worldRotateX += (worldRotateDestX-worldRotateX)/15;
  worldRotateY += (worldRotateDestY-worldRotateY)/15;
  translate(width/2,height/2,0);
//  rotateX(worldRotateX);
  rotateY(-worldRotateY/6);
  scale(worldZ/100);
  translate(-width/2,-height/2,-0);
  boolean toggled = false;
  translate(worldX,worldY/6,0);
  
//  buffert.beginDraw();
//  buffert.background(color(255));
//  buffert.translate(width/2,height/2,0);
//  buffert.rotateX(worldRotateX);
//  buffert.rotateY(-worldRotateY);
//  buffert.scale(worldZ/100);
//  buffert.translate(-width/2,-height/2,-0);
//  buffert.translate(worldX,worldY,0);
//  for(int i = 0; i< photos.size();i++){
//    Photo p = (Photo)photos.get(i);
//    p.drawBuffer(buffert);
//   
//  }
//  buffert.endDraw();

  for(int i = 0; i< photos.size();i++){
    Photo p = (Photo)photos.get(i);
    println("photo"+i);
    if(p.loading && p.img.width >0){
      p.doneLoading();
    }
    
    
//    if(buffert.get(mouseX,mouseY) == -(p.id+2)){
//      p.currentWidth = p.smallWidth*1.5;
//      p.currentHeight = p.smallHeight*1.5;
//      p.z =10;
//      toggled = true;
//    }
//    else{
//      p.currentWidth = p.smallWidth;
//      p.currentHeight = p.smallHeight;
//      p.z = 0;
//    }


    p.drawImage(g);
    g.removeCache(p.img);
      }
      
  popMatrix();
  
  }
}

void 
keyPressed() {
 
 if(keyCode == UP){
  visualMode = 1; 
 }
 
 if(keyCode == DOWN){
  visualMode = 2;
 }
}


void mouseWheel(int delta) {
  destZ -= delta*30;
  if(destZ < 25){
    destZ = 25;
  }
}

//void loadImagesFromApiCall(String callURL){
//  photos.clear();
//  xml = new XMLElement(this, callURL);
//  XMLElement photoList = xml.getChild(0);
//  int childCount = photoList.getChildCount();
//  int perRow = childCount/5;
//  worldWidth = (perRow+1)*120;
//  worldHeight = 6*120;
//  int yPos = 0;
//  for(int i = 0; i < childCount;i++){
//    String farm = photoList.getChild(i).getAttribute("farm");
//    String server = photoList.getChild(i).getAttribute("server");
//    String id = photoList.getChild(i).getAttribute("id");
//    String secret = photoList.getChild(i).getAttribute("secret");
//    if(i%perRow == 0){
//      yPos++;
//    }
//    photos.add(new Photo("http://farm"+farm+".static.flickr.com/"+server+"/"+id+"_"+secret+".jpg",i%perRow,yPos,i+1));
//  }
//}

void loadImagesFromFolder(){
  
  int childCount = filenames.length;
  int perRow = childCount/4;
  worldWidth = (perRow+1)*120;
  worldHeight = 6*120;
  int yPos = 0;
  for(int i = 0; i < childCount;i++){
    String name = filenames[i];
    if(i%perRow == 0){
      yPos++;
    }
    println(i+"Photo");
    photos.add(new Photo("/Users/villehenriksson/Documents/Koulu/Sisällöntuotannon projektityö/Python Materiaalit/Snapshots/VtmInsta/photoSample/" + name,i%perRow ,yPos,i+1));
  }
}

