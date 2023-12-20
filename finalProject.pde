import controlP5.*;

ControlP5 cp5;
Button resetButton;
Star[] stars;
ArrayList<Constellation> constellations;
int numStars = 400;
Star selectedStar = null;
boolean isPaused = false;
float angleX, angleY;
float zoom = 0;
int highlightedStarIndex = -1;
boolean starHighlighted = false;

void setup() {
  size(1200, 800, P3D);
  stars = new Star[numStars];
  for (int i = 0; i < numStars; i++) {
    stars[i] = new Star();
  }

  cp5 = new ControlP5(this);
  setupControls();
  constellations = new ArrayList<Constellation>();
}

void setupControls() {

  resetButton = cp5.addButton("Reset View")
    .setPosition(20, 50)
    .setSize(100, 20)
    .onPress(e -> resetView());
}

void draw() {
  background(0);
  lights();
  pushMatrix();
  translate(width / 2, height / 2, -500 + zoom);
  rotateX(angleX);
  rotateY(angleY);

  for (Star s : stars) s.show();
  popMatrix();

  for (Constellation c : constellations) c.draw();

  displayInstructions();
}

void displayInstructions() {
  fill(255);
  textSize(20);
  text("Use LEFT and RIGHT arrows to select stars. Press SPACE to create a constellation.", 30, height - 30);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT || keyCode == LEFT) {
      highlightedStarIndex = keyCode == RIGHT ?
        (highlightedStarIndex + 1) % numStars :
        (highlightedStarIndex - 1 + numStars) % numStars;
      starHighlighted = true;
    }
  } else if (key == ' ' && starHighlighted) {
    handleStarSelection();
  }
}

void handleStarSelection() {
  Star currentStar = stars[highlightedStarIndex];
  if (selectedStar == null) {
    selectedStar = currentStar;
  } else if (currentStar != selectedStar) {
    selectedStar.inConstellation = true;
    currentStar.inConstellation = true;
    constellations.add(new Constellation(selectedStar, currentStar));
    selectedStar = null;
  }
  starHighlighted = false;
  highlightedStarIndex = -1;
}

void mouseWheel(MouseEvent event) {
  zoom -= event.getCount() * 20;
}

void mouseDragged() {
  angleY += (mouseX - pmouseX) * 0.01;
  angleX += (mouseY - pmouseY) * 0.01;
}

void resetView() {
  angleX = angleY = zoom = 0;
}


class Star {
  PVector position;
  float size;
  boolean inConstellation = false;

  Star() {
    PVector randomDirection = PVector.random3D();
    float radius = random(300, 500);
    position = randomDirection.mult(radius);
    size = random(1.0, 2.0);
  }

  void show() {
    pushMatrix();
    translate(position.x, position.y, position.z);
    if (starHighlighted && stars[highlightedStarIndex] == this) {
      fill(255, 215, 0); // Gold color for highlighting
    } else if (this == selectedStar) {
      fill(255, 50, 0);
    } else {
      fill(255);
    }
    noStroke();
    sphere(size * 3);
    popMatrix();
  }
}

class Constellation {
  Star star1, star2;
  float pulse = 0;
  int colorIndex = 0;
  color[] colors = {color(150, 150, 255), color(200, 200, 255), color(255, 255, 255)};

  Constellation(Star star1, Star star2) {
    this.star1 = star1;
    this.star2 = star2;
  }

  void draw() {
    pulse += 0.05;
    float glow = sin(pulse) * 50 + 200;
    stroke(colors[colorIndex], glow);
    if (frameCount % 120 == 0) colorIndex = (colorIndex + 1) % colors.length;

    pushMatrix();
    translate(width / 2, height / 2, -500 + zoom);
    rotateX(angleX);
    rotateY(angleY);
    strokeWeight(2);
    line(star1.position.x, star1.position.y, star1.position.z,
      star2.position.x, star2.position.y, star2.position.z);
    popMatrix();
  }
}
