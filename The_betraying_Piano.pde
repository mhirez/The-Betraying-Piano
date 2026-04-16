import processing.sound.*;

// Cursor
PImage cursorImg;
int cursorW = 40;
int cursorH = 50;

// Adjust these so the red dot sits exactly on the cursor tip
int cursorTipOffsetX = 20;
int cursorTipOffsetY = 18;

// Turn this on/off for testing the real click point
boolean showTipDebug = true;

// White keys musically, but drawn BLACK
int numWhiteKeys = 14;
int[] keyX = new int[numWhiteKeys];
int[] keyY = new int[numWhiteKeys];
int[] keyW = new int[numWhiteKeys];
int[] keyH = new int[numWhiteKeys];

// Black keys musically, but drawn WHITE
int blackW, blackH;

// Store black key positions for detection
int[] blackKeyX;
int[] blackKeyIndex;
int numBlackKeys = 0;

// Pattern of musical black keys
boolean[] blackPattern = { true, true, false, true, true, true, false };

// Sound
SinOsc[] whiteOsc = new SinOsc[numWhiteKeys];
SinOsc[] blackOsc;

float[] whiteFreq = {
  261.63, // C4
  293.66, // D4
  329.63, // E4
  349.23, // F4
  392.00, // G4
  440.00, // A4
  493.88, // B4
  523.25, // C5
  587.33, // D5
  659.25, // E5
  698.46, // F5
  783.99, // G5
  880.00, // A5
  987.77  // B5
};

float[] blackFreq = {
  277.18, // C#4
  311.13, // D#4
  369.99, // F#4
  415.30, // G#4
  466.16, // A#4
  554.37, // C#5
  622.25, // D#5
  739.99, // F#5
  830.61, // G#5
  932.33  // A#5
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
  // Screen setup
  size(900, 500);
  surface.setTitle("The Betraying Piano");

  // Load cursor image
  cursorImg = loadImage("CURSOR.png");

  // Hide default cursor
  noCursor();

  // White keys musically, but drawn black
  int keyWidth = width / numWhiteKeys;
  int keyHeight = 300;
  int startY = 100;

  for (int i = 0; i < numWhiteKeys; i++) {
    keyX[i] = i * keyWidth;
    keyY[i] = startY;
    keyW[i] = keyWidth;
    keyH[i] = keyHeight;
  }

  // Black keys musically, but drawn white
  blackW = keyW[0] / 2;
  blackH = keyH[0] * 2 / 3;

  int count = 0;
  for (int i = 0; i < numWhiteKeys - 1; i++) {
    if (blackPattern[i % 7]) {
      count++;
    }
  }

  blackKeyX = new int[count];
  blackKeyIndex = new int[count];
  blackOsc = new SinOsc[count];

  int b = 0;
  for (int i = 0; i < numWhiteKeys - 1; i++) {
    if (blackPattern[i % 7]) {
      blackKeyX[b] = keyX[i] + keyW[i] - blackW / 2;
      blackKeyIndex[b] = i;
      b++;
    }
  }

  numBlackKeys = count;

  // Create one oscillator for each white key
  for (int i = 0; i < numWhiteKeys; i++) {
    whiteOsc[i] = new SinOsc(this);
  }

  // Create one oscillator for each black key
  for (int i = 0; i < numBlackKeys; i++) {
    blackOsc[i] = new SinOsc(this);
  }
}

void draw() {
  background(137, 207, 240);

  // Draw white keys musically, but filled black
  for (int i = 0; i < numWhiteKeys; i++) {
    fill(0);
    stroke(255);
    rect(keyX[i], keyY[i], keyW[i], keyH[i]);
  }

  // Draw black keys musically, but filled white
  for (int i = 0; i < numWhiteKeys - 1; i++) {
    if (blackPattern[i % 7]) {
      int x = keyX[i] + keyW[i] - blackW / 2;
      int y = keyY[i];

      fill(255);
      stroke(0);
      rect(x, y, blackW, blackH);
    }
  }

  // Draw cursor
  image(cursorImg, mouseX, mouseY, cursorW, cursorH);

  // Debug red dot = actual click point
  if (showTipDebug) {
    int tipX = mouseX + cursorTipOffsetX;
    int tipY = mouseY + cursorTipOffsetY;

    fill(255, 0, 0);
    noStroke();
    ellipse(tipX, tipY, 6, 6);
  }
}

void mousePressed() {
  // Actual detection point = cursor tip, not top-left of image
  int tipX = mouseX + cursorTipOffsetX;
  int tipY = mouseY + cursorTipOffsetY;

  // Check black keys first
  for (int b = 0; b < numBlackKeys; b++) {
    int x = blackKeyX[b];
    int y = keyY[0];

    if (tipX >= x && tipX <= x + blackW &&
        tipY >= y && tipY <= y + blackH) {

      println("Black key " + b + " clicked - " + blackNames[b] + " (drawn white)");
      playNoteThread(blackOsc[b], blackFreq[b]);
      return;
    }
  }

  // Then check white keys
  for (int i = 0; i < numWhiteKeys; i++) {
    if (tipX >= keyX[i] && tipX <= keyX[i] + keyW[i] &&
        tipY >= keyY[i] && tipY <= keyY[i] + keyH[i]) {

      println("White key " + i + " clicked - " + whiteNames[i] + " (drawn black)");
      playNoteThread(whiteOsc[i], whiteFreq[i]);
      return;
    }
  }
}

void playNoteThread(final SinOsc osc, final float freq) {
  new Thread(new Runnable() {
    public void run() {
      osc.stop();
      osc.freq(freq);
      osc.amp(0.3);
      osc.play();

      try {
        Thread.sleep(250);
      } catch (InterruptedException e) {
      }

      osc.stop();
    }
  }).start();
}
