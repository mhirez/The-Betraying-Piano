import processing.sound.*;
import java.util.ArrayList;
import java.awt.Desktop;
import java.net.URI;

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
int prevMouseX, prevMouseY;
boolean cursorInitialized = false;

// =========================
// Stage system
// Stage 1 = 0-10
// Stage 2 = 11-19
// Stage 3 = 20+
// =========================
int pressCount = 0;
int stage = 1;

// =========================
// White keys musically
// (but drawn BLACK)
// =========================
int numWhiteKeys = 14;
int[] keyX = new int[numWhiteKeys];
int[] keyY = new int[numWhiteKeys];
int[] keyW = new int[numWhiteKeys];
int[] keyH = new int[numWhiteKeys];

int[] currentWhiteX = new int[numWhiteKeys];
int[] currentWhiteY = new int[numWhiteKeys];
int[] currentWhiteW = new int[numWhiteKeys];
int[] currentWhiteH = new int[numWhiteKeys];

boolean[] whiteVisible = new boolean[numWhiteKeys];
boolean[] whiteBroken = new boolean[numWhiteKeys];

// =========================
// Black keys musically
// (but drawn WHITE)
// =========================
int blackW, blackH;
int[] blackKeyX;
int numBlackKeys = 0;

int[] currentBlackX;
int[] currentBlackY;
int[] currentBlackW;
int[] currentBlackH;

boolean[] blackVisible;
boolean[] blackBroken;

boolean[] blackPattern = { true, true, false, true, true, true, false };

// =========================
// Sound
// =========================
SinOsc[] whiteOsc = new SinOsc[numWhiteKeys];
SinOsc[] blackOsc;

ArrayList<SinOsc> hauntingOscs = new ArrayList<SinOsc>();

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

// =========================
// Phase 7 visual feedback
// =========================
int pressedWhiteIndex = -1;
int pressedBlackIndex = -1;
int pressedUntil = 0;

// =========================
// Phase 7 movement / drift
// =========================
float driftX = 0;
float driftY = 0;
float driftVX = 0.35;
float driftVY = 0.08;

// =========================
// Phase 7 setup flags
// =========================
boolean stage2FlawsInitialized = false;
boolean stage3FlawsInitialized = false;

// Optional surprise
boolean enableYouTubeSurprise = true;

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

    currentWhiteX[i] = keyX[i];
    currentWhiteY[i] = keyY[i];
    currentWhiteW[i] = keyW[i];
    currentWhiteH[i] = keyH[i];

    whiteVisible[i] = true;
    whiteBroken[i] = false;
  }

  blackW = keyW[0] / 2;
  blackH = keyH[0] * 2 / 3;

  int count = 0;
  for (int i = 0; i < numWhiteKeys - 1; i++) {
    if (blackPattern[i % 7]) {
      count++;
    }
  }

  numBlackKeys = count;

  blackKeyX = new int[numBlackKeys];
  currentBlackX = new int[numBlackKeys];
  currentBlackY = new int[numBlackKeys];
  currentBlackW = new int[numBlackKeys];
  currentBlackH = new int[numBlackKeys];
  blackVisible = new boolean[numBlackKeys];
  blackBroken = new boolean[numBlackKeys];
  blackOsc = new SinOsc[numBlackKeys];

  int b = 0;
  for (int i = 0; i < numWhiteKeys - 1; i++) {
    if (blackPattern[i % 7]) {
      blackKeyX[b] = keyX[i] + keyW[i] - blackW / 2;
      currentBlackX[b] = blackKeyX[b];
      currentBlackY[b] = keyY[0];
      currentBlackW[b] = blackW;
      currentBlackH[b] = blackH;
      blackVisible[b] = true;
      blackBroken[b] = false;
      b++;
    }
  }

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

  updateCursor();
  updateDrift();
  updateKeyGeometry();
  drawWhiteKeys();
  drawBlackKeys();

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

void updateCursor() {
  if (!cursorInitialized) {
    fakeCursorX = constrain(mouseX, 0, width - cursorW);
    fakeCursorY = constrain(mouseY, 0, height - cursorH);
    prevMouseX = mouseX;
    prevMouseY = mouseY;
    cursorInitialized = true;
    return;
  }

  int dx = mouseX - prevMouseX;
  int dy = mouseY - prevMouseY;

  if (stage >= 3) {
    // Cursed Cursor
    fakeCursorX -= dx;
    fakeCursorY -= dy;
  } else {
    fakeCursorX += dx;
    fakeCursorY += dy;
  }

  fakeCursorX = constrain(fakeCursorX, 0, width - cursorW);
  fakeCursorY = constrain(fakeCursorY, 0, height - cursorH);

  prevMouseX = mouseX;
  prevMouseY = mouseY;
}

void updateDrift() {
  if (stage >= 3) {
    // Piano Drift
    driftX += driftVX;
    driftY += driftVY;
  }
}

void updateKeyGeometry() {
  int driftOffsetX = round(driftX);
  int driftOffsetY = round(driftY);

  for (int i = 0; i < numWhiteKeys; i++) {
    currentWhiteX[i] = keyX[i] + driftOffsetX;
    currentWhiteY[i] = keyY[i] + driftOffsetY;

    if (stage >= 3) {
      // Key Deformation
      currentWhiteW[i] = max(28, keyW[i] + int(random(-18, 19)));
      currentWhiteH[i] = max(150, keyH[i] + int(random(-35, 36)));
    } else {
      currentWhiteW[i] = keyW[i];
      currentWhiteH[i] = keyH[i];
    }
  }

  for (int b = 0; b < numBlackKeys; b++) {
    currentBlackX[b] = blackKeyX[b] + driftOffsetX;
    currentBlackY[b] = keyY[0] + driftOffsetY;

    if (stage >= 3) {
      // Key Deformation
      currentBlackW[b] = max(14, blackW + int(random(-8, 9)));
      currentBlackH[b] = max(85, blackH + int(random(-20, 21)));
    } else {
      currentBlackW[b] = blackW;
      currentBlackH[b] = blackH;
    }
  }
}

void drawWhiteKeys() {
  for (int i = 0; i < numWhiteKeys; i++) {
    if (!whiteVisible[i]) {
      continue;
    }

    boolean showFeedback = (stage < 3) && (millis() < pressedUntil) && (pressedWhiteIndex == i);

    if (showFeedback) {
      fill(70, 150, 255);
    } else {
      fill(0);
    }

    stroke(255);
    rect(currentWhiteX[i], currentWhiteY[i], currentWhiteW[i], currentWhiteH[i]);
  }
}

void drawBlackKeys() {
  for (int b = 0; b < numBlackKeys; b++) {
    if (!blackVisible[b]) {
      continue;
    }

    boolean showFeedback = (stage < 3) && (millis() < pressedUntil) && (pressedBlackIndex == b);

    if (showFeedback) {
      fill(255, 230, 90);
    } else {
      fill(255);
    }

    stroke(0);
    rect(currentBlackX[b], currentBlackY[b], currentBlackW[b], currentBlackH[b]);
  }
}

void mousePressed() {
  int tipX = fakeCursorX + cursorTipOffsetX;
  int tipY = fakeCursorY + cursorTipOffsetY;

  // Check black keys first
  for (int b = 0; b < numBlackKeys; b++) {
    if (!blackVisible[b]) {
      continue;
    }

    if (tipX >= currentBlackX[b] && tipX <= currentBlackX[b] + currentBlackW[b] &&
        tipY >= currentBlackY[b] && tipY <= currentBlackY[b] + currentBlackH[b]) {
      handleBlackKeyPress(b);
      return;
    }
  }

  // Then white keys
  for (int i = 0; i < numWhiteKeys; i++) {
    if (!whiteVisible[i]) {
      continue;
    }

    if (tipX >= currentWhiteX[i] && tipX <= currentWhiteX[i] + currentWhiteW[i] &&
        tipY >= currentWhiteY[i] && tipY <= currentWhiteY[i] + currentWhiteH[i]) {
      handleWhiteKeyPress(i);
      return;
    }
  }
}

void handleBlackKeyPress(int b) {
  pressCount++;
  updateStage();

  if (stage < 3) {
    pressedBlackIndex = b;
    pressedWhiteIndex = -1;
    pressedUntil = millis() + 140;
  }

  // Nope Key
  if (blackBroken[b]) {
    println("Black key " + b + " clicked - " + blackNames[b] +
            " (drawn white) | Nope Key | Press Count: " + pressCount +
            " | Stage: " + stage);
    maybeTriggerYouTubeSurprise();
    return;
  }

  float playedFreq = blackFreq[b];
  String playedName = blackNames[b];
  boolean lied = false;
  int delayMs = 0;
  boolean haunted = false;
  boolean retired = false;

  // Note Liar
  if (stage >= 2 && random(1) < 0.30) {
    playedFreq = getRandomDifferentFrequency(playedFreq);
    playedName = getNoteNameForFrequency(playedFreq);
    lied = true;
  }

  // Sound Delay
  if (stage >= 2 && random(1) < 0.35) {
    delayMs = int(random(150, 601));
  }

  // Audio Haunting
  if (stage >= 3 && random(1) < 0.25) {
    haunted = true;
  }

  // Key Retirement
  if (stage >= 2 && countVisibleBlackKeys() > 3 && random(1) < 0.18) {
    blackVisible[b] = false;
    retired = true;
  }

  println("Black key " + b + " clicked - " + blackNames[b] +
          " (drawn white) | Played: " + playedName +
          formatFlawText(lied, delayMs, haunted, retired) +
          " | Press Count: " + pressCount +
          " | Stage: " + stage);

  playKeyWithFlaws(blackOsc[b], playedFreq, delayMs, haunted);
  maybeTriggerYouTubeSurprise();
}

void handleWhiteKeyPress(int i) {
  pressCount++;
  updateStage();

  if (stage < 3) {
    pressedWhiteIndex = i;
    pressedBlackIndex = -1;
    pressedUntil = millis() + 140;
  }

  // Nope Key
  if (whiteBroken[i]) {
    println("White key " + i + " clicked - " + whiteNames[i] +
            " (drawn black) | Nope Key | Press Count: " + pressCount +
            " | Stage: " + stage);
    maybeTriggerYouTubeSurprise();
    return;
  }

  float playedFreq = whiteFreq[i];
  String playedName = whiteNames[i];
  boolean lied = false;
  int delayMs = 0;
  boolean haunted = false;
  boolean retired = false;

  // Note Liar
  if (stage >= 2 && random(1) < 0.30) {
    playedFreq = getRandomDifferentFrequency(playedFreq);
    playedName = getNoteNameForFrequency(playedFreq);
    lied = true;
  }

  // Sound Delay
  if (stage >= 2 && random(1) < 0.35) {
    delayMs = int(random(150, 601));
  }

  // Audio Haunting
  if (stage >= 3 && random(1) < 0.25) {
    haunted = true;
  }

  // Key Retirement
  if (stage >= 2 && countVisibleWhiteKeys() > 6 && random(1) < 0.18) {
    whiteVisible[i] = false;
    retired = true;
  }

  println("White key " + i + " clicked - " + whiteNames[i] +
          " (drawn black) | Played: " + playedName +
          formatFlawText(lied, delayMs, haunted, retired) +
          " | Press Count: " + pressCount +
          " | Stage: " + stage);

  playKeyWithFlaws(whiteOsc[i], playedFreq, delayMs, haunted);
  maybeTriggerYouTubeSurprise();
}

void updateStage() {
  int previousStage = stage;

  if (pressCount <= 10) {
    stage = 1;
  } else if (pressCount <= 19) {
    stage = 2;
  } else {
    stage = 3;
  }

  if (!stage2FlawsInitialized && stage >= 2) {
    initializeStage2Flaws();
  }

  if (!stage3FlawsInitialized && stage >= 3) {
    initializeStage3Flaws();
  }

  if (stage != previousStage) {
    println("=== Stage changed to " + stage + " ===");
  }
}

void initializeStage2Flaws() {
  stage2FlawsInitialized = true;

  markRandomBrokenWhiteKeys(2);
  markRandomBrokenBlackKeys(1);
}

void initializeStage3Flaws() {
  stage3FlawsInitialized = true;

  driftVX = 0.35;
  driftVY = 0.08;
}

void markRandomBrokenWhiteKeys(int amount) {
  int marked = 0;

  while (marked < amount) {
    int i = int(random(numWhiteKeys));
    if (!whiteBroken[i]) {
      whiteBroken[i] = true;
      marked++;
    }
  }
}

void markRandomBrokenBlackKeys(int amount) {
  int marked = 0;

  while (marked < amount) {
    int b = int(random(numBlackKeys));
    if (!blackBroken[b]) {
      blackBroken[b] = true;
      marked++;
    }
  }
}

int countVisibleWhiteKeys() {
  int count = 0;
  for (int i = 0; i < numWhiteKeys; i++) {
    if (whiteVisible[i]) {
      count++;
    }
  }
  return count;
}

int countVisibleBlackKeys() {
  int count = 0;
  for (int b = 0; b < numBlackKeys; b++) {
    if (blackVisible[b]) {
      count++;
    }
  }
  return count;
}

float getRandomDifferentFrequency(float originalFreq) {
  float candidate = originalFreq;

  while (abs(candidate - originalFreq) < 0.001) {
    int totalNotes = whiteFreq.length + blackFreq.length;
    int randomIndex = int(random(totalNotes));

    if (randomIndex < whiteFreq.length) {
      candidate = whiteFreq[randomIndex];
    } else {
      candidate = blackFreq[randomIndex - whiteFreq.length];
    }
  }

  return candidate;
}

String getNoteNameForFrequency(float freq) {
  for (int i = 0; i < whiteFreq.length; i++) {
    if (abs(whiteFreq[i] - freq) < 0.001) {
      return whiteNames[i];
    }
  }

  for (int b = 0; b < blackFreq.length; b++) {
    if (abs(blackFreq[b] - freq) < 0.001) {
      return blackNames[b];
    }
  }

  return "?";
}

String formatFlawText(boolean lied, int delayMs, boolean haunted, boolean retired) {
  String text = "";

  if (lied) {
    text += " | Note Liar";
  }

  if (delayMs > 0) {
    text += " | Sound Delay " + delayMs + "ms";
  }

  if (haunted) {
    text += " | Audio Haunting";
  }

  if (retired) {
    text += " | Key Retirement";
  }

  return text;
}

void maybeTriggerYouTubeSurprise() {
  if (stage >= 3 && enableYouTubeSurprise && random(1) < 0.04) {
    try {
      if (Desktop.isDesktopSupported()) {
        Desktop.getDesktop().browse(new URI("https://www.youtube.com/watch?v=dQw4w9WgXcQ"));
      }
    }
    catch (Exception e) {
      println("YouTube Surprise failed: " + e.getMessage());
    }
  }
}

void drawStageInfo() {
  String stageLabel = "";

  if (stage == 1) {
    stageLabel = "Stage 1: Trustworthy";
  } else if (stage == 2) {
    stageLabel = "Stage 2: Something Is Wrong";
  } else {
    stageLabel = "Stage 3: Full Chaos";
  }

  fill(255);
  stroke(0);
  strokeWeight(2);
  rect(15, 15, 275, 65, 10);

  fill(0);
  textAlign(LEFT, TOP);
  textSize(18);
  text("Press Count: " + pressCount, 25, 25);
  text(stageLabel, 25, 50);
}

void playKeyWithFlaws(final SinOsc osc, final float freq, final int delayMs, final boolean haunted) {
  final PApplet sketchRef = this;

  new Thread(new Runnable() {
    public void run() {
      try {
        if (delayMs > 0) {
          Thread.sleep(delayMs);
        }
      }
      catch (InterruptedException e) {
      }

      if (haunted) {
        SinOsc hauntOsc = new SinOsc(sketchRef);
        hauntOsc.freq(freq);
        hauntOsc.amp(0.6);
        hauntOsc.play();
        hauntingOscs.add(hauntOsc);
      } else {
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
    }
  }).start();
}

// Testing helper: press R to stop all haunted notes
void keyPressed() {
  if (key == 'r' || key == 'R') {
    stopAllHaunting();
  }
}

void stopAllHaunting() {
  for (SinOsc osc : hauntingOscs) {
    osc.stop();
  }
  hauntingOscs.clear();
  println("All haunted notes stopped.");
}
