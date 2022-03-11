class Agent {
  PVector pos, prevPos, vel;
  float speed = 5;
  int steps = 2;
  boolean alive = true;
  color c;
  float theta = PI / 10;
  float d = 20.0;

  Agent(float x, float y) {
    this.pos = new PVector(x, y);
    this.prevPos = pos.copy();
    //this.c = color(map(random(1), 0, 1, 0, 50));
    //this.c = color(map(random(1), 0, 1, 20, 255));

    colorMode(HSB, 360.0);
    float h = map(random(1), 0, 1, lh, rh);
    float b = map(random(1), 0, 1, 0, 360);
    if (random(1) < 0.1) {
      h = (h + 120) % 360;
    }
    //} else if (random(1) < 0.11){
    //  h = (h - 120) % 360;
    //}
    this.c = color(h, 360, b);
    colorMode(RGB, 255);
    //colorMode(HSB, 1.0);
    //this.c = color(map(random(1), 0, 1, 0.3, 1), 1, 1);
    //colorMode(RGB, 255);


    //this.c = color(0, 0, map(random(1), 0, 1, 0.9, 1));
  }

  float step_speed(int attempt, int max_attempts) {
    return max(2, speed * (1 - (attempt / float(max_attempts))));
  }

  PVector baseVel(float randomness) {

    PVector v = new PVector();
    PVector h = PVector.sub(this.pos, this.prevPos).normalize();
    if (h.mag() == 0) {
      v = PVector.sub(this.pos, center);
    } else {
      PVector l = h.copy().rotate(PI * 0.5);
      PVector m = h.copy();
      PVector r = h.copy().rotate(PI * -0.5);
      float l_weight = sense(l, d);
      float m_weight = sense(m, d);
      float r_weight = sense(r, d);
      float weight = brightness(this.c);
      float l_diff = abs(l_weight - weight);
      float m_diff = abs(m_weight - weight);
      float r_diff = abs(r_weight - weight);
      //println(l_diff, m_diff, r_diff, brightness(this.c));
      float targetWeight;
      //if (brightness(this.c) < 70) {
      //  targetWeight = min(l_weight, m_weight, r_weight);
      //  println("min");
      //} else {
      //  targetWeight = max(l_weight, m_weight, r_weight);
      //  println("max");
      //}
      float minDiff = min(l_diff, m_diff, r_diff);
      //println(l_weight, m_weight, r_weight);
      //println(minWeight);
      if (l_weight == m_weight && m_weight == r_weight) {
        v = PVector.fromAngle(random(TAU));
      } else {
        //if (targetWeight == l_weight) v = l;
        //if (targetWeight == m_weight) v = m;
        //if (targetWeight == r_weight) v = r;
        if (minDiff == l_diff) v = l;
        if (minDiff == m_diff) v = m;
        if (minDiff == r_diff) v = r;
      }
    }
    //PVector v = PVector.sub(this.pos, center);
    float r_left = 0.2;
    float r_right = 0.2;
    v.rotate(map(random(1), 0, 1, PI * r_left, -PI * r_right));
    PVector random = PVector.fromAngle(random(TAU));
    return random(1) < 0.4 ? v : random;
    //return PVector.lerp(v, random, 0.8);
  }

  void update() {
    int attempts = 100;
    PVector candidate = new PVector();
    PVector v = new PVector();
    PVector s = new PVector();
    float progress;
    for (int a = 0; a < attempts; a++) {
      progress = a / (float) attempts;
      float a_speed = step_speed(a, attempts);
      v = baseVel(progress).setMag(a_speed);
      s = PVector.mult(v, 1.0 / steps);
      candidate.set(this.pos);

      boolean collision = false;
      for (int i = 0; i < steps; i++) {
        candidate.add(s);
        int px = (int) candidate.x;
        int py = (int) candidate.y;
        if (px < 0 || px >= width || py < 0 || py >= height) {
          collision = true;
          break;
        }
        if (PVector.sub(center, candidate).mag() > width / 2.5) {
          collision = true;
          break;
        }
        // other agent collision check
        color val = agentLayer.pixels[py * width + px];
        if (brightness(val) > 100) {
          collision = true;
          break;
        }
      }
      // if all steps passed, collision will still be false
      if (!collision) {
        this.prevPos.set(pos);
        this.pos.add(v);
        return;
      }
    }
    this.alive = false;
  }

  float sense(PVector dir, float s) {
    dir.normalize();
    PVector base = PVector.add(this.pos, dir.copy().mult(10));
    dir.mult(s);
    PVector half_s = dir.copy().mult(0.5);
    PVector across = PVector.add(base, dir);
    PVector a = PVector.add(across, half_s.copy().rotate(HALF_PI));
    PVector b = PVector.add(across, half_s.copy().rotate(-HALF_PI));
    PVector c = PVector.add(base, half_s.copy().rotate(HALF_PI));
    int startRow = (int) min(a.y, b.y, c.y);
    int endRow = (int) max(a.y, b.y, c.y);
    startRow = constrain(startRow, 0, height-1);
    endRow = constrain(endRow, 0, height-1);
    int startCol = (int) min(a.x, b.x, c.x);
    int endCol = (int) max(a.x, b.x, c.x);
    startCol = constrain(startCol, 0, height-1);
    endCol = constrain(endCol, 0, height-1);
    float sum = 0;
    int count = 0;
    for (int row = startRow; row < endRow; row++) {
      for (int col = startCol; col < endCol; col++) {
        sum += brightness(bgLayer.pixels[row * width + col]);
        count++;
      }
    }
    return sum / count;
  }

  void show(PGraphics canvas) {
    canvas.stroke(this.c, 10);
    canvas.strokeWeight(0.5);
    canvas.line(this.prevPos.x, this.prevPos.y, this.pos.x, this.pos.y);
  }
}
