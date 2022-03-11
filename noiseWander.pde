float noiseScale;
int lh = 135;
int rh = 175;
int lrange = 60;
int numAgents = 5000;
PGraphics agentLayer;
PGraphics bgLayer;
float radius;
Agent[] agents;
PVector center;
int iterations = 200;
int seed;

void bgNoise() {
  bgLayer.beginDraw();
  bgLayer.loadPixels();
  for (int r = 0; r < width; r++) {
    for (int c = 0; c < height; c++) {
      float x = r * noiseScale;
      float y = c * noiseScale;
      float baseN = noise(x, y);
      int n = (int)map(baseN, 0, 1, 0, 255);
      bgLayer.pixels[r * width + c] = color(n);
    }
  }
  bgLayer.updatePixels();
  bgLayer.endDraw();
}

Agent[] phyllotaxis() {
  agents = new Agent[numAgents];
  float disp = radius / agents.length;
  float theta = 0;
  for (int i = 0; i < agents.length; i++, theta += 137.5) {
    float ax = (i * disp) * sin(theta) + width / 2;
    float ay = (i * disp) * cos(theta) + height / 2;
    agents[i] = new Agent(ax, ay);
  }
  return agents;
}

void setup() {
  size(1000, 1000);
  background(0);
  smooth(10);
  seed = (int)random(5000);
  randomSeed(seed);

  center = new PVector(width / 2, height / 2);
  radius = width / 2.5;
  noiseScale = 0.01 + map(random(1), 0, 1, -0.02, 0.02);
  lh = (int) random(360);
  rh = (lh + lrange) % 360;

  bgLayer = createGraphics(width, height);
  agentLayer = createGraphics(width, height);

  agents = phyllotaxis();
}

void draw() {
  for (int iter = 0; iter < iterations; iter++) {

    bgLayer.beginDraw();
    bgLayer.loadPixels();
    println(iter);
    agentLayer.beginDraw();
    agentLayer.loadPixels();
    for (int i = 0; i < agents.length; i++) {
      Agent a = agents[i];
      if (a.alive) {
        a.update();
        a.show(agentLayer);
      }
    }
    agentLayer.endDraw();
    bgLayer.endDraw();
    image(bgLayer, 0, 0);
    image(agentLayer, 0, 0);
  }
  saveFrame(String.format("out2/%d-####.tif", seed));
  noLoop();
}
