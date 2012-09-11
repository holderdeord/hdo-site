$(function () {
  $('.slide-out-div').tabSlideOut({
    tabHandle: '.handle',                     //class of the element that will become your tab
    pathToTabImage: '/assets/feedback.png', //path to the image for the tab //Optionally can be set  css
    imageHeight: '135px',                     //height of tab image           //Optionally can be set using css
    imageWidth: '20px',                       //width of tab image            //Optionally can be set using css
    tabLocation: 'right',                      //side of screen where tab lives, top, right, bottom, or left
    speed: 300,                               //speed of animation
    action: 'click',                          //options: 'click' or 'hover', action to trigger animation
    topPos: '50%',                          //position from the top/ use if tabLocation is left or right
    fixedPosition: true                      //options: true makes it stick(fixed position) on scroll
  });
});