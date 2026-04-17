import processing.sound.*;

// =========================
// Cursor
// =========================
PImage cursorImg;
int cursorW = 40;
int cursorH = 50;

int cursorTipOffsetX = 20;
int cursorTipOffsetY = 18;

boolean showTipDebug = false;

int fakeCursorX, fakeCursorY;

// =========================
// White keys musically
// (but drawn BLACK)
// =========================
int numWhiteKeys = 14;
int[] keyX = new int[numWhiteKeys];
int[] keyY = new int[numWhiteKeys];
int[] keyW = new int[numWhiteKeys];
int[] keyH = new int[numWhiteKeys];

// =========================
// Black keys musically
// (but drawn WHITE)
// =========================
int blackW, blackH;
int[] blackKeyX;
int numBlackKeys = 0;

boolean[] blackPattern = { true, true, false, true, true, true, false };

// =========================
// Phase 6
// =========================
int pressCount = 0;
int stage = 1;

// =========================
// Sound
// =========================
SinOsc[] whiteOsc = new SinOsc[numWhiteKeys];
SinOsc[] blackOsc;

float[] whiteFreq = {
  261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88,
  523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77
};

float[] blackFreq = {
  277.18, 311.13, 369.99, 415.30, 466.16,
  554.37, 622.25, 739.99, 830.61, 932.33
};

String[] whiteNames = {
  "C4", "D4", "E4", "F4", "G4", "A4", "B4",
  "C5", "D5", "E5", "F5", "G5", "A5", "B5"
};

String[] blackNames = {
  "C#4", "D#4", "F#4", "G#4", "A#4",
  "C#5", "D#5", "F#5", "G#5", "A#5"
};

void setup() {
  size(900, 500);
  surface.setTitle("The Betraying Piano");

  cursorImg = loadImage("CURSOR.png");
  noCursor();

  int keyWidth = width / numWhiteKeys;
  int keyHeight = 300;
  int startY = 100;

  for (int i = 0; i < numWhiteKeys; i++) {
    keyX[i] = i * keyWidth;
    keyY[i] = startY;
    keyW[i] = keyWidth;
    keyH[i] = keyHeight;
  }

  blackW = keyW[0] / 2;
  blackH = keyH[0] * 2 / 3;

  int count = 0;
  for (int i = 0; i < numWhiteKeys - 1; i++) {
    if (blackPattern[i % 7]) {
      count++;
    }
  }

  blackKeyX = new int[count];
  blackOsc = new SinOsc[count];

  int b = 0;
  for (int i = 0; i < numWhiteKeys - 1; i++) {
    if (blackPattern[i % 7]) {
      blackKeyX[b] = keyX[i] + keyW[i] - blackW / 2;
      b++;
    }
  }

  numBlackKeys = count;

  for (int i = 0; i < numWhiteKeys; i++) {
    whiteOsc[i] = new SinOsc(this);
  }

  for (int i = 0; i < numBlackKeys; i++) {
    blackOsc[i] = new SinOsc(this);
  }

  updateStage();
}

void draw() {
  background(137, 207, 240);

  fakeCursorX = constrain(mouseX, 0, width - cursorW);
  fakeCursorY = constrain(mouseY, 0, height - cursorH);

  // White keys musically, drawn black
  for (int i = 0; i < numWhiteKeys; i++) {
    fill(0);
    stroke(255);
    rect(keyX[i], keyY[i], keyW[i], keyH[i]);
  }

  // Black keys musically, drawn white
  for (int i = 0; i < numWhiteKeys - 1; i++) {
    if (blackPattern[i % 7]) {
      int x = keyX[i] + keyW[i] - blackW / 2;
      int y = keyY[i];

      fill(255);
      stroke(0);
      rect(x, y, blackW, blackH);
    }
  }

  image(cursorImg, fakeCursorX, fakeCursorY, cursorW, cursorH);

  if (showTipDebug) {
    int tipX = fakeCursorX + cursorTipOffsetX;
    int tipY = fakeCursorY + cursorTipOffsetY;

    fill(255, 0, 0);
    noStroke();
    ellipse(tipX, tipY, 6, 6);
  }

  drawStageInfo();
}

void mousePressed() {
  int tipX = fakeCursorX + cursorTipOffsetX;
  int tipY = fakeCursorY + cursorTipOffsetY;

  // Check black keys first
  for (int b = 0; b < numBlackKeys; b++) {
    int x = blackKeyX[b];
    int y = keyY[0];

    if (tipX >= x && tipX <= x + blackW &&
        tipY >= y && tipY <= y + blackH) {

      pressCount++;
      updateStage();

      println("Black key " + b + " clicked - " + blackNames[b] +
              " (drawn white) | Press Count: " + pressCount +
              " | Stage: " + stage);

      playNoteThread(blackOsc[b], blackFreq[b]);
      return;
    }
  }

  // Then white keys
  for (int i = 0; i < numWhiteKeys; i++) {
    if (tipX >= keyX[i] && tipX <= keyX[i] + keyW[i] &&
        tipY >= keyY[i] && tipY <= keyY[i] + keyH[i]) {

      pressCount++;
      updateStage();

      println("White key " + i + " clicked - " + whiteNames[i] +
              " (drawn black) | Press Count: " + pressCount +
              " | Stage: " + stage);

      playNoteThread(whiteOsc[i], whiteFreq[i]);
      return;
    }
  }
}

void updateStage() {
  if (pressCount <= 10) {
    stage = 1;
  } else if (pressCount <= 19) {
    stage = 2;
  } else {
    stage = 3;
  }
}

void drawStageInfo() {
  fill(255);
  stroke(0);
  strokeWeight(2);
  rect(15, 15, 220, 65);

  fill(0);
  textAlign(LEFT, TOP);
  textSize(18);
  text("Press Count: " + pressCount, 25, 25);
  text("Stage: " + stage, 25, 50);
}

void playNoteThread(final SinOsc osc, final float freq) {
  new Thread(new Runnable() {
    public void run() {
      osc.stop();
      osc.freq(freq);
      osc.amp(0.6);
      osc.play();

      try {
        Thread.sleep(250);
      }
      catch (InterruptedException e) {
      }

      osc.stop();
    }
  }).start();
}
