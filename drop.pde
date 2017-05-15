/**
 * Обработчик события "drag and drop" на главном окне
 */
void dropEvent(DropEvent theDropEvent) {

  // if the dropped object is an image, then 
  // load the image into our PImage.
  if (theDropEvent.isImage()) {

    img = theDropEvent.loadImage();

    while (!img.isLoaded()) {
      delay(10);
    }

    loadPicture();
  }
}