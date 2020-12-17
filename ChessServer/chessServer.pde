import processing.net.*;

Server myServer;

color lightbrown = #FFFFC3;
color darkbrown = #D8864E;
color red = #F45D4C;

PImage wrook, wbishop, wknight, wqueen, wking, wpawn;
PImage brook, bbishop, bknight, bqueen, bking, bpawn;

boolean firstClick;
boolean myTurn = true;

int row1, col1; //row and col clicked first
int row2, col2; //row and col clicked second

boolean zkey;
boolean possibleToUndo = false;

char lastPieceTaken;

//char stores a single character
char grid[][] = {
  {'R', 'B', 'N', 'Q', 'K', 'N', 'B', 'R'}, //capital = black pieces
  {'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'}, 
  {'r', 'b', 'n', 'q', 'k', 'n', 'b', 'r'}, //lowercase = white pieces
};


void setup() {
  size(800, 800);

  myServer = new Server(this, 1234);

  firstClick = true;
  
  brook = loadImage("blackRook.png");
  bbishop = loadImage("blackBishop.png");
  bknight = loadImage("blackKnight.png");
  bqueen = loadImage("blackQueen.png");
  bking = loadImage("blackKing.png");
  bpawn = loadImage("blackPawn.png");

  wrook = loadImage("whiteRook.png");
  wbishop = loadImage("whiteBishop.png");
  wknight = loadImage("whiteKnight.png");
  wqueen = loadImage("whiteQueen.png");
  wking = loadImage("whiteKing.png");
  wpawn = loadImage("whitePawn.png");
}


void draw() {
  drawBoard();
  drawPieces();
  receiveMove();
  highlight();
}


void highlight() {
  if (firstClick == false) {
    noFill();
    stroke(red); 
    strokeWeight(5);
    rect(col1*100, row1*100, 100, 100);
  }
  if (firstClick == true) {
    noFill();
    strokeWeight(1);
    stroke(0);
  }
}


void receiveMove() {
  Client myclient = myServer.available();
  if (myclient != null) {
    String incoming = myclient.readString();
    int r1 = int(incoming.substring(0, 1)); 
    int c1 = int(incoming.substring(2, 3));
    int r2 = int(incoming.substring(4, 5));
    int c2 = int(incoming.substring(6, 7)); 
    //int ID = int(incoming.substring(8, 9));
    grid[r2][c2] = grid[r1][c1]; //whatever was at r1 c1 will be copied over to r2 c2
    grid[r1][c1] = ' '; //clear r1 c1
    myTurn = true;          
    //check when making move - if pawn reaches other side - then open menu for pawn promotion
  }

  //UNDO MOVE
  if (myTurn == false) {
    possibleToUndo = true;
    if (zkey) {
      grid[row1][col1] = grid[row2][col2];
      grid[row2][col2] = lastPieceTaken;
      myTurn = true;
      possibleToUndo = false;
    }
  }
}


void drawBoard() {
  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) {
      if ((c%2) == (r%2)) {
        fill(lightbrown);
      } else {
        fill(darkbrown);
      }
      stroke(0);
      strokeWeight(1);
      rect(c*100, r*100, 100, 100);
    }
  }
}


void drawPieces() {
  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) {
      if (grid[r][c] == 'r') image(wrook, c*100, r*100, 100, 100);
      if (grid[r][c] == 'b') image(wbishop, c*100, r*100, 100, 100);
      if (grid[r][c] == 'n') image(wknight, c*100, r*100, 100, 100);
      if (grid[r][c] == 'q') image(wqueen, c*100, r*100, 100, 100);
      if (grid[r][c] == 'k') image(wking, c*100, r*100, 100, 100);
      if (grid[r][c] == 'p') image(wpawn, c*100, r*100, 100, 100);

      if (grid[r][c] == 'R') image(brook, c*100, r*100, 100, 100);
      if (grid[r][c] == 'B') image(bbishop, c*100, r*100, 100, 100);
      if (grid[r][c] == 'N') image(bknight, c*100, r*100, 100, 100);
      if (grid[r][c] == 'Q') image(bqueen, c*100, r*100, 100, 100);
      if (grid[r][c] == 'K') image(bking, c*100, r*100, 100, 100);
      if (grid[r][c] == 'P') image(bpawn, c*100, r*100, 100, 100);
    }
  }
}


void mouseReleased() {
  if (myTurn == true) {
    if (firstClick) {
      row1 = mouseY/100;
      col1 = mouseX/100;
      firstClick = false;
    } else {
      row2 = mouseY/100;
      col2 = mouseX/100;
      if (!(row2 == row1 && col2 == col1)) {
        grid[row2][col2] = grid[row1][col1];
        grid[row1][col1] = ' ';
        grid[row1][col1] = lastPieceTaken;
        myServer.write(row1 + "," + col1 + "," + row2 + "," + col2);
        firstClick = true;
        myTurn = false;
      }
    }
  }
}


void keyPressed() {
  if (key == 'z' || key == 'Z') zkey = true;
}

void keyReleased() {
  if (key == 'z' || key == 'Z') zkey = false;
}
