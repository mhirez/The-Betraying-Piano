import processing.sound.*;   // AI-assisted
import java.util.ArrayList;  // AI-assisted
import java.awt.Desktop;     // AI-assisted
import java.net.URI;         // AI-assisted

// =========================
// Cursor
// =========================
PImage cursorImg; // AI-assisted
int cursorW = 40; // AI-assisted
int cursorH = 50; // AI-assisted

int cursorTipOffsetX = 20; // Shared
int cursorTipOffsetY = 18; // Shared

int fakeCursorX, fakeCursorY; // Human logic
int prevMouseX, prevMouseY;   // Human logic
boolean cursorInitialized = false; // Shared

// =========================
// Stage system
// Stage 1 = 0-10
// Stage 2 = 11-19
// Stage 3 = 20+
// =========================
int pressCount = 0; // Human logic
int stage = 1;      // Human logic

// =========================
// White keys musically
// (but drawn BLACK)
// =========================
int numWhiteKeys = 14; // Shared
int[] keyX = new int[numWhiteKeys]; // AI-assisted
int[] keyY = new int[numWhiteKeys]; // AI-assisted
int[] keyW = new int[numWhiteKeys]; // AI-assisted
int[] keyH = new int[numWhiteKeys]; // AI-assisted

int[] currentWhiteX = new int[numWhiteKeys]; // AI-assisted
int[] currentWhiteY = new int[numWhiteKeys]; // AI-assisted
int[] currentWhiteW = new int[numWhiteKeys]; // AI-assisted
int[] currentWhiteH = new int[numWhiteKeys]; // AI-assisted

boolean[] whiteVisible = new boolean[numWhiteKeys]; // Shared
boolean[] whiteBroken = new boolean[numWhiteKeys];  // Human logic

// =========================
// Black keys musically
// (but drawn WHITE)
// =========================
int numBlackKeys = 10; // Shared
int blackW, blackH; // AI-assisted
int[] blackKeyX = new int[numBlackKeys];    // AI-assisted

int[] currentBlackX = new int[numBlackKeys]; // AI-assisted
int[] currentBlackY = new int[numBlackKeys]; // AI-assisted
int[] currentBlackW = new int[numBlackKeys]; // AI-assisted
int[] currentBlackH = new int[numBlackKeys]; // AI-assisted

boolean[] blackVisible = new boolean[numBlackKeys]; // Shared
boolean[] blackBroken = new boolean[numBlackKeys];  // Human logic

boolean[] blackPattern = { true, true, false, true, true, true, false }; // Shared

// =========================
// Sound
// =========================
SinOsc[] whiteOsc = new SinOsc[numWhiteKeys]; // AI-assisted
SinOsc[] blackOsc = new SinOsc[numBlackKeys]; // AI-assisted

ArrayList<SinOsc> hauntingOscs = new ArrayList<SinOsc>(); // Human logic

float[] whiteFreq = { // Shared
  261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88,
  523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77
};

float[] blackFreq = { // Shared
  277.18, 311.13, 369.99, 415.30, 466.16,
  554.37, 622.25, 739.99, 830.61, 932.33
};

String[] whiteNames = { // Shared
  "C4", "D4", "E4", "F4", "G4", "A4", "B4",
  "C5", "D5", "E5", "F5", "G5", "A5", "B5"
};

String[] blackNames = { // Shared
  "C#4", "D#4", "F#4", "G#4", "A#4",
  "C#5", "D#5", "F#5", "G#5", "A#5"
};

// =========================
// Phase 7 visual feedback
// =========================
int pressedWhiteIndex = -1; // Shared
int pressedBlackIndex = -1; // Shared
int pressedUntil = 0;       // Shared

// =========================
// Phase 7 movement / drift
// =========================
float driftX = 0;    // Human logic
float driftY = 0;    // Human logic
float driftVX = 0.35; // Human logic
float driftVY = 0.08; // Human logic

// =========================
// Phase 7 setup flags
// =========================
boolean stage2FlawsInitialized = false; // Human logic
boolean stage3FlawsInitialized = false; // Human logic

// Optional surprise
boolean enableYouTubeSurprise = true; // Human logic

void setup() { // Shared
  size(900, 500); // AI-assisted
  surface.setTitle("The Betraying Piano"); // Shared

  cursorImg = loadImage("CURSOR.png"); // AI-assisted
  noCursor(); // Human logic

  int keyWidth = width / numWhiteKeys; // AI-assisted
  int keyHeight = 300; // AI-assisted
  int startY = 100; // AI-assisted

  for (int i = 0; i < numWhiteKeys; i++) { // AI-assisted
    keyX[i] = i * keyWidth; // AI-assisted
    keyY[i] = startY; // AI-assisted
    keyW[i] = keyWidth; // AI-assisted
    keyH[i] = keyHeight; // AI-assisted

    currentWhiteX[i] = keyX[i]; // AI-assisted
    currentWhiteY[i] = keyY[i]; // AI-assisted
    currentWhiteW[i] = keyW[i]; // AI-assisted
    currentWhiteH[i] = keyH[i]; // AI-assisted

    whiteVisible[i] = true; // Shared
    whiteBroken[i] = false; // Shared
  }

  blackW = keyW[0] / 2; // AI-assisted
  blackH = keyH[0] * 2 / 3; // AI-assisted

 
  int b = 0; // AI-assisted
  for (int i = 0; i < numWhiteKeys - 1; i++) { // AI-assisted
    if (blackPattern[i % 7]) { // AI-assisted
      blackKeyX[b] = keyX[i] + keyW[i] - blackW / 2; // AI-assisted
      currentBlackX[b] = blackKeyX[b]; // AI-assisted
      currentBlackY[b] = keyY[0]; // AI-assisted
      currentBlackW[b] = blackW; // AI-assisted
      currentBlackH[b] = blackH; // AI-assisted
      blackVisible[b] = true; // Shared
      blackBroken[b] = false; // Shared
      b++; // AI-assisted
    }
  }

  for (int i = 0; i < numWhiteKeys; i++) { // AI-assisted
    whiteOsc[i] = new SinOsc(this); // AI-assisted
  }

  for (int i = 0; i < numBlackKeys; i++) { // AI-assisted
    blackOsc[i] = new SinOsc(this); // AI-assisted
  }

  updateStage(); // Human logic
}

void draw() { // Shared
  background(137, 207, 240); // AI-assisted

  updateCursor(); // Human logic
  updateDrift(); // Human logic
  updateKeyGeometry(); // Shared
  drawWhiteKeys(); // AI-assisted
  drawBlackKeys(); // AI-assisted

  image(cursorImg, fakeCursorX, fakeCursorY, cursorW, cursorH); // AI-assisted

  drawStageInfo(); // Shared
}

void updateCursor() { // Human logic
  if (!cursorInitialized) { // Shared
    fakeCursorX = constrain(mouseX, 0, width - cursorW); // Shared
    fakeCursorY = constrain(mouseY, 0, height - cursorH); // Shared
    prevMouseX = mouseX; // Shared
    prevMouseY = mouseY; // Shared
    cursorInitialized = true; // Shared
    return;
  }

  int dx = mouseX - prevMouseX; // Shared
  int dy = mouseY - prevMouseY; // Shared

  if (stage >= 3) { // Human logic
    // Cursed Cursor
    fakeCursorX -= dx; // Human logic
    fakeCursorY -= dy; // Human logic
  } else {
    fakeCursorX += dx; // Shared
    fakeCursorY += dy; // Shared
  }

  fakeCursorX = constrain(fakeCursorX, 0, width - cursorW); // Shared
  fakeCursorY = constrain(fakeCursorY, 0, height - cursorH); // Shared

  prevMouseX = mouseX; // Shared
  prevMouseY = mouseY; // Shared
}

void updateDrift() { // Human logic
  if (stage >= 3) { // Human logic
    // Piano Drift
    driftX += driftVX; // Human logic
    driftY += driftVY; // Human logic
  }
}

void updateKeyGeometry() { // Shared
  int driftOffsetX = round(driftX); // Shared
  int driftOffsetY = round(driftY); // Shared

  for (int i = 0; i < numWhiteKeys; i++) { // Shared
    currentWhiteX[i] = keyX[i] + driftOffsetX; // Shared
    currentWhiteY[i] = keyY[i] + driftOffsetY; // Shared

    if (stage >= 3) { // Human logic
      // Key Deformation
      currentWhiteW[i] = max(28, keyW[i] + int(random(-18, 19))); // Shared
      currentWhiteH[i] = max(150, keyH[i] + int(random(-35, 36))); // Shared
    } else {
      currentWhiteW[i] = keyW[i]; // AI-assisted
      currentWhiteH[i] = keyH[i]; // AI-assisted
    }
  }

  for (int b = 0; b < numBlackKeys; b++) { // Shared
    currentBlackX[b] = blackKeyX[b] + driftOffsetX; // Shared
    currentBlackY[b] = keyY[0] + driftOffsetY; // Shared

    if (stage >= 3) { // Human logic
      // Key Deformation
      currentBlackW[b] = max(14, blackW + int(random(-8, 9))); // Shared
      currentBlackH[b] = max(85, blackH + int(random(-20, 21))); // Shared
    } else {
      currentBlackW[b] = blackW; // AI-assisted
      currentBlackH[b] = blackH; // AI-assisted
    }
  }
}

void drawWhiteKeys() { // AI-assisted
  for (int i = 0; i < numWhiteKeys; i++) { // AI-assisted
    if (!whiteVisible[i]) { // Shared
      continue;
    }

    boolean showFeedback = (stage < 3) && (millis() < pressedUntil) && (pressedWhiteIndex == i); // Shared

    if (showFeedback) { // Shared
      fill(70, 150, 255); // AI-assisted
    } else {
      fill(0); // AI-assisted
    }

    stroke(255); // AI-assisted
    rect(currentWhiteX[i], currentWhiteY[i], currentWhiteW[i], currentWhiteH[i]); // AI-assisted
  }
}

void drawBlackKeys() { // AI-assisted
  for (int b = 0; b < numBlackKeys; b++) { // AI-assisted
    if (!blackVisible[b]) { // Shared
      continue;
    }

    boolean showFeedback = (stage < 3) && (millis() < pressedUntil) && (pressedBlackIndex == b); // Shared

    if (showFeedback) { // Shared
      fill(255, 230, 90); // AI-assisted
    } else {
      fill(255); // AI-assisted
    }

    stroke(0); // AI-assisted
    rect(currentBlackX[b], currentBlackY[b], currentBlackW[b], currentBlackH[b]); // AI-assisted
  }
}

void mousePressed() { // Shared
  int tipX = fakeCursorX + cursorTipOffsetX; // Human logic
  int tipY = fakeCursorY + cursorTipOffsetY; // Human logic

  // Check black keys first
  for (int b = 0; b < numBlackKeys; b++) { // AI-assisted
    if (!blackVisible[b]) { // Shared
      continue;
    }

    if (tipX >= currentBlackX[b] && tipX <= currentBlackX[b] + currentBlackW[b] &&
        tipY >= currentBlackY[b] && tipY <= currentBlackY[b] + currentBlackH[b]) { // Shared
      handleBlackKeyPress(b); // Human logic
      return;
    }
  }

  // Then white keys
  for (int i = 0; i < numWhiteKeys; i++) { // AI-assisted
    if (!whiteVisible[i]) { // Shared
      continue;
    }

    if (tipX >= currentWhiteX[i] && tipX <= currentWhiteX[i] + currentWhiteW[i] &&
        tipY >= currentWhiteY[i] && tipY <= currentWhiteY[i] + currentWhiteH[i]) { // Shared
      handleWhiteKeyPress(i); // Human logic
      return;
    }
  }
}

void handleBlackKeyPress(int b) { // Shared
  pressCount++; // Human logic
  updateStage(); // Human logic

  if (stage < 3) { // Shared
    pressedBlackIndex = b; // Shared
    pressedWhiteIndex = -1; // Shared
    pressedUntil = millis() + 140; // Shared
  }

  // Nope Key
  if (blackBroken[b]) { // Human logic
    println("Black key " + b + " clicked - " + blackNames[b] +
            " (drawn white) | Nope Key | Press Count: " + pressCount +
            " | Stage: " + stage); // Shared
    maybeTriggerYouTubeSurprise(); // Human logic
    return;
  }

  float playedFreq = blackFreq[b]; // Shared
  String playedName = blackNames[b]; // Shared
  boolean lied = false; // Human logic
  int delayMs = 0; // Human logic
  boolean haunted = false; // Human logic
  boolean retired = false; // Human logic

  // Note Liar
  if (stage >= 2 && random(1) < 0.30) { // Human logic
    playedFreq = getRandomDifferentFrequency(playedFreq); // Shared
    playedName = getNoteNameForFrequency(playedFreq); // Shared
    lied = true; // Human logic
  }

  // Sound Delay
  if (stage >= 2 && random(1) < 0.35) { // Human logic
    delayMs = int(random(150, 601)); // Shared
  }

  // Audio Haunting
  if (stage >= 3 && random(1) < 0.25) { // Human logic
    haunted = true; // Human logic
  }

  // Key Retirement
  if (stage >= 2 && countVisibleBlackKeys() > 3 && random(1) < 0.18) { // Human logic
    blackVisible[b] = false; // Human logic
    retired = true; // Human logic
  }

  println("Black key " + b + " clicked - " + blackNames[b] +
          " (drawn white) | Played: " + playedName +
          formatFlawText(lied, delayMs, haunted, retired) +
          " | Press Count: " + pressCount +
          " | Stage: " + stage); // Shared

  playKeyWithFlaws(blackOsc[b], playedFreq, delayMs, haunted); // Shared
  maybeTriggerYouTubeSurprise(); // Human logic
}

void handleWhiteKeyPress(int i) { // Shared
  pressCount++; // Human logic
  updateStage(); // Human logic

  if (stage < 3) { // Shared
    pressedWhiteIndex = i; // Shared
    pressedBlackIndex = -1; // Shared
    pressedUntil = millis() + 140; // Shared
  }

  // Nope Key
  if (whiteBroken[i]) { // Human logic
    println("White key " + i + " clicked - " + whiteNames[i] +
            " (drawn black) | Nope Key | Press Count: " + pressCount +
            " | Stage: " + stage); // Shared
    maybeTriggerYouTubeSurprise(); // Human logic
    return;
  }

  float playedFreq = whiteFreq[i]; // Shared
  String playedName = whiteNames[i]; // Shared
  boolean lied = false; // Human logic
  int delayMs = 0; // Human logic
  boolean haunted = false; // Human logic
  boolean retired = false; // Human logic

  // Note Liar
  if (stage >= 2 && random(1) < 0.30) { // Human logic
    playedFreq = getRandomDifferentFrequency(playedFreq); // Shared
    playedName = getNoteNameForFrequency(playedFreq); // Shared
    lied = true; // Human logic
  }

  // Sound Delay
  if (stage >= 2 && random(1) < 0.35) { // Human logic
    delayMs = int(random(150, 601)); // Shared
  }

  // Audio Haunting
  if (stage >= 3 && random(1) < 0.25) { // Human logic
    haunted = true; // Human logic
  }

  // Key Retirement
  if (stage >= 2 && countVisibleWhiteKeys() > 6 && random(1) < 0.18) { // Human logic
    whiteVisible[i] = false; // Human logic
    retired = true; // Human logic
  }

  println("White key " + i + " clicked - " + whiteNames[i] +
          " (drawn black) | Played: " + playedName +
          formatFlawText(lied, delayMs, haunted, retired) +
          " | Press Count: " + pressCount +
          " | Stage: " + stage); // Shared

  playKeyWithFlaws(whiteOsc[i], playedFreq, delayMs, haunted); // Shared
  maybeTriggerYouTubeSurprise(); // Human logic
}

void updateStage() { // Human logic
  int previousStage = stage; // Human logic

  if (pressCount <= 10) { // Human logic
    stage = 1; // Human logic
  } else if (pressCount <= 19) { // Human logic
    stage = 2; // Human logic
  } else {
    stage = 3; // Human logic
  }

  if (!stage2FlawsInitialized && stage >= 2) { // Human logic
    initializeStage2Flaws(); // Human logic
  }

  if (!stage3FlawsInitialized && stage >= 3) { // Human logic
    initializeStage3Flaws(); // Human logic
  }

  if (stage != previousStage) { // Human logic
    println("=== Stage changed to " + stage + " ==="); // Shared
  }
}

void initializeStage2Flaws() { // Human logic
  stage2FlawsInitialized = true; // Human logic

  markRandomBrokenWhiteKeys(2); // Human logic
  markRandomBrokenBlackKeys(1); // Human logic
}

void initializeStage3Flaws() { // Human logic
  stage3FlawsInitialized = true; // Human logic

  driftVX = 0.35; // Human logic
  driftVY = 0.08; // Human logic
}

void markRandomBrokenWhiteKeys(int amount) { // Human logic
  int marked = 0; // Shared

  while (marked < amount) { // Shared
    int i = int(random(numWhiteKeys)); // Shared
    if (!whiteBroken[i]) { // Shared
      whiteBroken[i] = true; // Human logic
      marked++; // Shared
    }
  }
}

void markRandomBrokenBlackKeys(int amount) { // Human logic
  int marked = 0; // Shared

  while (marked < amount) { // Shared
    int b = int(random(numBlackKeys)); // Shared
    if (!blackBroken[b]) { // Shared
      blackBroken[b] = true; // Human logic
      marked++; // Shared
    }
  }
}

int countVisibleWhiteKeys() { // AI-assisted
  int count = 0; // AI-assisted
  for (int i = 0; i < numWhiteKeys; i++) { // AI-assisted
    if (whiteVisible[i]) { // Shared
      count++; // AI-assisted
    }
  }
  return count; // AI-assisted
}

int countVisibleBlackKeys() { // AI-assisted
  int count = 0; // AI-assisted
  for (int b = 0; b < numBlackKeys; b++) { // AI-assisted
    if (blackVisible[b]) { // Shared
      count++; // AI-assisted
    }
  }
  return count; // AI-assisted
}

float getRandomDifferentFrequency(float originalFreq) { // Shared
  float candidate = originalFreq; // Shared

  while (abs(candidate - originalFreq) < 0.001) { // Shared
    int totalNotes = whiteFreq.length + blackFreq.length; // AI-assisted
    int randomIndex = int(random(totalNotes)); // Shared

    if (randomIndex < whiteFreq.length) { // Shared
      candidate = whiteFreq[randomIndex]; // Shared
    } else {
      candidate = blackFreq[randomIndex - whiteFreq.length]; // Shared
    }
  }

  return candidate; // Shared
}

String getNoteNameForFrequency(float freq) { // AI-assisted
  for (int i = 0; i < whiteFreq.length; i++) { // AI-assisted
    if (abs(whiteFreq[i] - freq) < 0.001) { // AI-assisted
      return whiteNames[i]; // AI-assisted
    }
  }

  for (int b = 0; b < blackFreq.length; b++) { // AI-assisted
    if (abs(blackFreq[b] - freq) < 0.001) { // AI-assisted
      return blackNames[b]; // AI-assisted
    }
  }

  return "?"; // AI-assisted
}

String formatFlawText(boolean lied, int delayMs, boolean haunted, boolean retired) { // Shared
  String text = ""; // AI-assisted

  if (lied) { // Human logic
    text += " | Note Liar"; // Human logic
  }

  if (delayMs > 0) { // Human logic
    text += " | Sound Delay " + delayMs + "ms"; // Human logic
  }

  if (haunted) { // Human logic
    text += " | Audio Haunting"; // Human logic
  }

  if (retired) { // Human logic
    text += " | Key Retirement"; // Human logic
  }

  return text; // Shared
}

void maybeTriggerYouTubeSurprise() { // Human logic
  if (stage >= 3 && enableYouTubeSurprise && random(1) < 0.04) { // Human logic
    try {
      if (Desktop.isDesktopSupported()) { // AI-assisted
        Desktop.getDesktop().browse(new URI("https://www.youtube.com/watch?v=dQw4w9WgXcQ")); // Human logic
      }
    }
    catch (Exception e) {
      println("YouTube Surprise failed: " + e.getMessage()); // Shared
    }
  }
}

void drawStageInfo() { // Shared
  String stageLabel = ""; // Shared

  if (stage == 1) { // Human logic
    stageLabel = "Stage 1: Trustworthy"; // Human logic
  } else if (stage == 2) { // Human logic
    stageLabel = "Stage 2: Something Is Wrong"; // Human logic
  } else {
    stageLabel = "Stage 3: Full Chaos"; // Human logic
  }

  fill(255); // AI-assisted
  stroke(0); // AI-assisted
  strokeWeight(2); // AI-assisted
  rect(15, 15, 275, 65, 10); // AI-assisted

  fill(0); // AI-assisted
  textAlign(LEFT, TOP); // AI-assisted
  textSize(18); // AI-assisted
  text("Press Count: " + pressCount, 25, 25); // Shared
  text(stageLabel, 25, 50); // Shared
}

void playKeyWithFlaws(final SinOsc osc, final float freq, final int delayMs, final boolean haunted) { // Shared
  final PApplet sketchRef = this; // AI-assisted

  new Thread(new Runnable() { // AI-assisted
    public void run() { // AI-assisted
      try {
        if (delayMs > 0) { // Human logic
          Thread.sleep(delayMs); // Shared
        }
      }
      catch (InterruptedException e) {
      }

      if (haunted) { // Human logic
        SinOsc hauntOsc = new SinOsc(sketchRef); // AI-assisted
        hauntOsc.freq(freq); // AI-assisted
        hauntOsc.amp(0.6); // AI-assisted
        hauntOsc.play(); // AI-assisted
        hauntingOscs.add(hauntOsc); // Human logic
      } else {
        osc.stop(); // AI-assisted
        osc.freq(freq); // AI-assisted
        osc.amp(0.6); // AI-assisted
        osc.play(); // AI-assisted

        try {
          Thread.sleep(250); // AI-assisted
        }
        catch (InterruptedException e) {
        }

        osc.stop(); // AI-assisted
      }
    }
  }).start();
}
