float noiseScale = 0.01;
float lh = 135;
float rh = 175;
float lrange = 40;


int numAgents = 5000;
PGraphics agentLayer;
PGraphics bgLayer;
Agent[] agents;
PVector center;

Agent onDisk() {
  float r =  lerp(0, width / 2.5, pow(cos(random(1)), 4));
  float theta = random(TAU);
  float ax = r * sin(theta) + width / 2;
  float ay = r * cos(theta) + height / 2;
  return new Agent(ax, ay);
}

Agent uniform() {
  float x = random(width);
  float y = random(height);
  return new Agent(x, y);
}

void setup() {
  size(1200, 1200);
  smooth(10);
  center = new PVector(width / 2, height / 2);
  ///background(255);
  background(0);
  //blendMode(SCREEN);
  bgLayer = createGraphics(width, height);
  bgLayer.beginDraw();
  bgLayer.loadPixels();
  for (int r = 0; r < width; r++) {
    for (int c = 0; c < height; c++) {
      float x = r * noiseScale;
      float y = c * noiseScale;
      float baseN = noise(x,y);
      //baseN = pow(baseN * 2 - 1, 1/1.2) + 1;
      //baseN /= 2;
      int n = (int)map(baseN, 0, 1, 0, 255);

      bgLayer.pixels[r * width + c] = color(n);
    }
  }
  bgLayer.updatePixels();
  bgLayer.endDraw();
  lh = random(360);
  rh = (lh + lrange) % 360;

  agents = new Agent[numAgents];
  for (int i = 0; i < numAgents; i++) {
    agents[i] = onDisk();
  }
  agentLayer = createGraphics(width, height);
}

void draw() {
  println(frameCount);
  boolean revive = false;
  if (revive) {
    push();
    noStroke();
    fill(0, 8);
    rect(0, 0, width, height);
    pop();
  }

  //translate(width/2, height/2);
  boolean active = false;
  agentLayer.beginDraw();
  agentLayer.loadPixels();
  bgLayer.beginDraw();
  bgLayer.loadPixels();
  for (int i = 0; i < agents.length; i++) {
    Agent agent = agents[i];
    if (agent.alive) {
      active = true;
      agent.update();
      agent.show(agentLayer);
    } else {
      if (revive) {
        agents[i] = onDisk();
      }
    }
  }
  agentLayer.endDraw();
  bgLayer.endDraw();
  //image(bgLayer, 0, 0);
  image(agentLayer, 0, 0);
  if (!active) {
    //flood();
    saveFrame();
    noLoop();
  }
  if ((frameCount - 3) % 50 == 0) {
    saveFrame(String.format("%d_####.tif", (int)lh));
  }
  
  //if (frameCount > 5){
  // noLoop();
  //}
}

void keyPressed()
{
  if (key == 'a') {
    println("!");
    saveFrame();
  }
}
