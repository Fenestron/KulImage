/**
 * Стиль рисования, основанный на двух "движущихся точках". 
 * В итоге получаются "червячки", которые постепенно вырисовывают картину.
 * В зависимости от изменения параметров меняется поведение этих "червячков".
 * 
 */
class EmbroideryStyle extends Style {
  public EmbroideryStyle() {
    super();
    super.fps = fps;
    super.stylename = stylename;
    setControls(this);
  }

  private String stylename = "Embroidery Style";

  private int fps = 500;

  // Основные переменные стиля

  // Вектор передвижения
  private PVector aims = new PVector();
  // Список Seeker'ов
  private ArrayList < Seeker > seekers;
  private float seekX, seekY;
  // Максимальная длина "червяка"
  private int maxLength;
  // Массив, в котором хранится количество посещений каждого пикселя
  private int[] buffer;
  // Количество Seeker'ов
  private int seekNum;
  // Длина и ширина области рисования
  private int imgWidth;
  private int imgHeight;

  private float angle1;
  private float angle2;

  // Ограничение на радиус окружности в векторе отклонения
  private float devMax;

  // Размер (радиус) кисти 
  public float weight;

  /**
   * Установить параметры "по умолчанию"
   */
  public void setup() {

    imgWidth = img.width;
    imgHeight = img.height;

    pg.fill(0);

    seekNum = 2; // 200
    pg.fill(255);
    pg.stroke(255);
    //pg.rect( 0, 0, imgWidth, imgHeight );
    buffer = new int[imgHeight * imgWidth];
    pg.smooth();
    weight = .2; // .2
    maxLength = 30; // 300
    devMax = 4; // 4

    angle1 = 45;
    angle2 = 125;

    variables = new ArrayList < Variable > ();

    variables.add(new Variable("Длина", "maxLength", 2, 500, maxLength));
    variables.add(new Variable("Изогнутость", "devMax", 1, 20, devMax));
    variables.add(new Variable("Жирность", "weight", 0.001, 1, weight));

    variables.add(new Variable("Угол 1", "angle1", 0, 360, angle1));
    variables.add(new Variable("Угол 2", "angle2", 0, 360, angle2));

    // Синхронизация переменных между переменными интерфейса и класса
    for (Variable
      var: variables) {
      controlP5.Controller controller = cp5.getController(var.varName);
      if (controller != null) {
        controller.setValue(controller.getValue());
      }
    }


    pg.strokeJoin(ROUND);
    seekers = new ArrayList < Seeker > ();

    for (int i = 0; i < seekNum; i++) {
      Seeker mSeeker = new Seeker(new PVector(random(imgWidth), random(imgHeight)), new PVector(random(-3, 3), random(-3, 3)));
      seekers.add(mSeeker);
    }

  }

  /**
   * Одна итерация отрисовки данным стилем.
   * 
   */
  public void draw() {
    for (int i = 0; i < seekNum; i++) {
      Seeker mSeeker = seekers.get(i);
      drawing(mSeeker, i);
    }
  }

  /**
   * Итерация отрисовки для одного Seeker'a
   * 
   * Для каждого Seeker'a ищем вектор передвижения
   * и рисуем продолжение в соответствии с этим вектором.
   */
  private void drawing(Seeker mySeeker, int seekerId) {

    seekX = mySeeker.getP().x;
    seekY = mySeeker.getP().y;

    while (isBrush && (sq(xcord - seekX) + sq(ycord - seekY) > sq(sq(radius)) + 100)) {
      deplacePoint(mySeeker);
      seekX = mySeeker.getP().x;
      seekY = mySeeker.getP().y;
    }

    // Местоположение тестируемой точки в pixels[]
    int pixelsPosition = floor(seekX) + floor(seekY) * imgWidth;

    int locX = floor(seekX);
    int locY = floor(seekY);

    float angle;
    if (seekerId == 0) {
      angle = angle1;
    } else {
      angle = angle2;
    }

    float dev = angle / 45;

    if (dev < 1) {
      mySeeker.getV().x = 1;
      mySeeker.getV().y = -dev;
    } else if (dev < 3) {
      mySeeker.getV().x = 2 - dev;
      mySeeker.getV().y = -1;
    } else if (dev < 5) {
      mySeeker.getV().x = -1;
      mySeeker.getV().y = dev - 4;
    } else if (dev < 7) {
      mySeeker.getV().x = dev - 6;
      mySeeker.getV().y = 1;
    } else if (dev <= 8) {
      mySeeker.getV().x = 1;
      mySeeker.getV().y = 8 - dev;
    }

    // Объединяем вектора
    PVector deviation = mySeeker.getV().get();
    deviation.normalize();
    deviation.mult(devMax);
    // println("deviation: "+deviation);
    mySeeker.getV().normalize();
    mySeeker.getP().add(deviation);

    // Увеличиваем длину и перемещаемся дальше
    mySeeker.setLongueur(mySeeker.getLongueur() + 1);

    if (mySeeker.getLongueur() > maxLength) {
      deplacePoint(mySeeker);
    }
    if ((mySeeker.getP().x < 1) || (mySeeker.getP().y < 1) || (mySeeker.getP().x > imgWidth - 1) || (mySeeker.getP().y > imgHeight - 1)) {
      deplacePoint(mySeeker);
      return;
    }

    // Увеличиваем количество "посещений" каждого пикселя 
    buffer[pixelsPosition]++;

    // Действия, завязанные на количестве "посещений" каждой точки.

    // if (buffer[pixelsPosition]++ > 0) return;

    // Нулевое отклонение
    if ((deviation.x == 0) && (deviation.y == 0)) {
      deplacePoint(mySeeker);
    }

    // Рисование 
    mySeeker.setDia((float)(weight * (1 - cos((mySeeker.getLongueur()) * PI * 2 / (float) maxLength))));
    mySeeker.setAlpha((max(0, (round(127 * mySeeker.getDia() / weight)))));

    int x = (int) mySeeker.getP().x;
    int y = (int) mySeeker.getP().y;

    color c;
    c = img.get(x, y);

    pg.fill(c);
    pg.stroke(c, mySeeker.getAlpha());
    pg.strokeWeight(mySeeker.getDia());

    float startX = seekX;
    float startY = seekY;
    float stopX = mySeeker.getP().x;
    float stopY = mySeeker.getP().y;

    // if ((sq(xcord - stopX) + sq(ycord - stopY) > sq(radius)))
    //   return;

    pg.line(startX, startY, stopX, stopY);
  }

  /**
   * Функция перемещения Seeker'a
   */
  void deplacePoint(Seeker seeker) {
    seeker.setLongueur(0);
    setRandomP(seeker);

    seekX = seeker.getP().x;
    seekY = seeker.getP().y;
  }

  void setRandomP(Seeker seeker) {
    if (isBrush) {
      seeker.setP(xcord + random(-radius, radius), ycord + random(-radius, radius));
    } else {
      seeker.setP(random(1, imgWidth - 1), random(1, imgHeight - 1));
    }
  }


  /**
   * "Бегун", которые представляет из себя передвигающуюся точку.
   * 
   */
  public class Seeker {

    // Позиция
    private PVector p = new PVector();
    // Скорость
    private PVector v = new PVector();
    private int imgPixel;
    // Длина
    private float longueur;
    // Диаметр
    private float dia;
    private int alpha;

    public Seeker(PVector P, PVector V) {
      p = P;
      v = V;
      longueur = 0;
    }

    public float getLongueur() {
      return longueur;
    }

    public void setLongueur(float longueur) {
      this.longueur = longueur;
    }

    public PVector getP() {
      return p;
    }

    public void setP(float a, float b) {
      this.p.x = a;
      this.p.y = b;
    }

    public PVector getV() {
      return v;
    }

    public float getDia() {
      return dia;
    }

    public void setDia(float dia) {
      this.dia = dia;
    }

    public int getAlpha() {
      return alpha;
    }

    public void setAlpha(int alpha) {
      this.alpha = alpha;
    }

    public int getImgPixel() {
      if (getP().x > 0 && getP().x < imgWidth && getP().y > 0 && getP().y < imgHeight)
        return img.pixels[floor(getP().x) + floor(getP().y) * imgWidth];
      else {
        return 0;
      }
    }
  }
}