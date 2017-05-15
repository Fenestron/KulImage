/**
 * Стиль рисования, в котором за основу взято рисование "палочек".
 * Палочки - это линии заданного размера и длины, которые рисуются
 * от заданного пикселя до пикселя, отклоненного на косинус по x и
 * синус по y-координатах.
 */
class WandStyle extends Style {
  public WandStyle() {
    super();
    super.fps = fps;
    super.stylename = stylename;
    setControls(this);
  }

  private String stylename = "Wand Style";

  private int fps = 10;

  // Основные переменные стиля

  // Длина "палочки"
  private int length;
  // Расстояние между палочками
  private int distance;
  // Длина и ширина области рисования
  private int imgWidth;
  private int imgHeight;
  // Текущие координаты рисования
  private int x, y;
  // Ширина палочки 
  public float weight;

  private boolean isStart;

  /**
   * Установить параметры "по умолчанию"
   */
  public void setup() {

    imgWidth = img.width;
    imgHeight = img.height;

    pg.smooth();

    length = 3;
    distance = 3;
    weight = 1;
    x = 0;
    y = 0;
    isStart = false;

    variables = new ArrayList < Variable > ();

    variables.add(new Variable("Длина", "length", 1, 10, length));
    variables.add(new Variable("Расстояние", "distance", 1, 10, distance));
    variables.add(new Variable("Жирность", "weight", 1, 10, weight));


    // Синхронизация данных между переменными интерфейса и класса
    for (Variable
      var: variables) {
      controlP5.Controller controller = cp5.getController(var.varName);
      if (controller != null) {
        controller.setValue(controller.getValue());
      }
    }
  }

  /**
   * Одна итерация отрисовки данным стилем.
   * 
   */
  public void draw() {
    
    if (isBrush) {
      int left = (int) max(xcord - radius, 0);
      int top = (int) max(ycord - radius, 0);
      int right = (int) min(xcord + radius, imgWidth);
      int bottom = (int) min(ycord + radius, imgHeight);
      x = left;
      y = top;
      for (int i = 0; i < sq(2 * radius); ++i) {
        drawing(left, right, top, bottom);
      }
      return;
    }

    if (!isStart) {
      pg.background(0);
      isStart = true;
    }

    for (int i = 0; i < 1000; i++) {
      if (y > imgHeight - distance - 1) {
        cf.startButton();
        x = 0;
        y = 0;
        println(x / y);
        return;
      }
      drawing(0, imgWidth, 0, imgHeight);

    }
  }

  void drawing(int left, int right, int top, int bottom) {
    color c = img.get(x, y);

    float angle = map(brightness(c), 0, 255, 0, TWO_PI);
    float sw = map(brightness(c), 0, 255, 0.25, 2);

    float endX = x + cos(angle) * length;
    float endY = y + sin(angle) * length;

    pg.strokeWeight(sw * weight);

    pg.stroke(c);
    pg.line(x, y, endX, endY);

    x += distance;
    if (x > right) {
      x = left;
      y += distance;
      if (y > bottom) {
        y = top;
      }
    }
  }
}