/*
 * Swiper 1.8.7 - Mobile Touch Slider
 * http://www.idangero.us/sliders/swiper/
 *
 * Copyright 2012-2013, Vladimir Kharlampidi
 * The iDangero.us
 * http://www.idangero.us/
 *
 * Licensed under GPL & MIT
 *
 * Updated on: February 5, 2013
*/
Swiper = function(selector, params, callback) {
	
	/*=========================
	  A little bit dirty but required part for IE8 and old FF support
	  ===========================*/
	if (!window.addEventListener) {
		if (!window.Element)
			Element = function () { };
	
		Element.prototype.addEventListener = HTMLDocument.prototype.addEventListener = addEventListener = function (type, listener, useCapture) { this.attachEvent('on' + type, listener); }
		Element.prototype.removeEventListener = HTMLDocument.prototype.removeEventListener = removeEventListener = function (type, listener, useCapture) { this.detachEvent('on' + type, listener); }
	}
	
	if (document.body.__defineGetter__) {
		if (HTMLElement) {
			var element = HTMLElement.prototype;
			if (element.__defineGetter__)
				element.__defineGetter__("outerHTML", function () { return new XMLSerializer().serializeToString(this); } );
		}
	}
	
	if (!window.getComputedStyle) {
		window.getComputedStyle = function (el, pseudo) {
			this.el = el;
			this.getPropertyValue = function (prop) {
				var re = /(\-([a-z]){1})/g;
				if (prop == 'float') prop = 'styleFloat';
				if (re.test(prop)) {
					prop = prop.replace(re, function () {
						return arguments[2].toUpperCase();
					});
				}
				return el.currentStyle[prop] ? el.currentStyle[prop] : null;
			}
			return this;
		}
	}
		
	/* End Of Polyfills*/
	if(!(selector.nodeType))
		if (!document.querySelectorAll||document.querySelectorAll(selector).length==0) return;
	
	function dQ(s) {
		return document.querySelectorAll(s)
	}
	var _this = this
	_this.touches = {};
	_this.positions = {
		current : 0	
	};
	_this.id = (new Date()).getTime();
	_this.container = (selector.nodeType) ? selector : dQ(selector)[0];
	_this.times = {};
	_this.isTouched = false;
	_this.realIndex = 0;
	_this.activeSlide = 0;
    _this.previousSlide = null;
	_this.langDirection = window.getComputedStyle(_this.container, null).getPropertyValue('direction')
	/*=========================
	  New Support Object
	  ===========================*/
	_this.support = {
		touch : _this.isSupportTouch(),
		threeD : _this.isSupport3D()	
	}
	//For fallback with older versions
	_this.use3D = _this.support.threeD;
	
	
	/*=========================
	  Default Parameters
	  ===========================*/
	var defaults = {
		mode : 'horizontal',
		ratio : 1,
		speed : 300,
		freeMode : false,
		freeModeFluid : false,
		slidesPerSlide : 1,
		simulateTouch : true,
		followFinger : true,
		autoPlay:false,
		onlyExternal : false,
		createPagination : true,
		pagination : false,
		resistance : true,
		scrollContainer : false,
		preventLinks : true,
		initialSlide: 0,
		keyboardControl: false, 
		mousewheelControl : false,
		//Namespace
		slideClass : 'swiper-slide',
		wrapperClass : 'swiper-wrapper',
		paginationClass: 'swiper-pagination-switch'	,
		paginationActiveClass : 'swiper-active-switch' 
	}
	params = params || {};	
	for (var prop in defaults) {
		if (! (prop in params)) {
			params[prop] = defaults[prop]	
		}
	}
	_this.params = params;
	if (params.scrollContainer) {
		params.freeMode = true;
		params.freeModeFluid = true;	
	}
	var _widthFromCSS = false
	if (params.slidesPerSlide=='auto') {
		_widthFromCSS = true;
		params.slidesPerSlide = 1;
	}
	
	//Default Vars
	var	wrapper, isHorizontal,
	 slideSize, numOfSlides, wrapperSize, direction, isScrolling, containerSize;
	
	//Define wrapper
	for (var i = _this.container.childNodes.length - 1; i >= 0; i--) {
		
		if (_this.container.childNodes[i].className) {

			var _wrapperClasses = _this.container.childNodes[i].className.split(' ')

			for (var j = 0; j < _wrapperClasses.length; j++) {
				if (_wrapperClasses[j]===params.wrapperClass) {
					wrapper = _this.container.childNodes[i]
				}
			};	
		}
	};

	_this.wrapper = wrapper;
	//Mode
	isHorizontal = params.mode == 'horizontal';
		
	//Define Touch Events
	_this.touchEvents = {
		touchStart : _this.support.touch || !params.simulateTouch  ? 'touchstart' : (_this.ie10 ? 'MSPointerDown' : 'mousedown'),
		touchMove : _this.support.touch || !params.simulateTouch ? 'touchmove' : (_this.ie10 ? 'MSPointerMove' : 'mousemove'),
		touchEnd : _this.support.touch || !params.simulateTouch ? 'touchend' : (_this.ie10 ? 'MSPointerUp' : 'mouseup')
	};
	
	/*=========================
	  Slide API
	  ===========================*/
	_this._extendSwiperSlide = function  (el) {
	  	el.append = function () {
		  	_this.wrapper.appendChild(el);
		  	_this.reInit();
		  	return el;
		}
		el.prepend = function () {
			_this.wrapper.insertBefore(el, _this.wrapper.firstChild)
		  	_this.reInit();
		  	return el;
		}
		el.insertAfter = function (index) {
		  	if(typeof index === undefined) return false;
		  	var beforeSlide = _this.slides[index+1]
		 	_this.wrapper.insertBefore(el, beforeSlide)
		  	_this.reInit();
		  	return el;
		}
		el.clone = function () {
		  	return _this._extendSwiperSlide(el.cloneNode(true))
		}
		el.remove = function () {
		  	_this.wrapper.removeChild(el);
		  	_this.reInit()
		}
		el.html = function (html) {
		  	if (typeof html == undefined) {
		  		return el.innerHTML
		  	}
		  	else {
		  		el.innerHTML = html;
		  		return el;
		  	}
		}
		el.index = function () {
		  	var index
		  	for (var i = _this.slides.length - 1; i >= 0; i--) {
		  		if(el==_this.slides[i]) index = i
		  	};
		  	return index;
		}
		el.isActive = function () {
		  	if (el.index() == _this.activeSlide) return true;
		  	else return false;
		}
		if (!el.swiperSlideDataStorage) el.swiperSlideDataStorage={};
		el.getData = function (name) {
		  	return el.swiperSlideDataStorage[name]
		}
		el.setData = function (name, value) {
		  	el.swiperSlideDataStorage[name] = value;
		  	return el;
		}
		el.data = function (name, value) {
			if (!value) {
				return el.getAttribute('data-'+name);
			}
			else {
				el.setAttribute('data-'+name,value);
				return el;
			}
		}
		return el;
	}

	//Calculate information about slides
	_this._calcSlides = function () {
		var oldNumber = _this.slides ? _this.slides.length : false;
		_this.slides = []
		for (var i = 0; i < _this.wrapper.childNodes.length; i++) {
		 	if (_this.wrapper.childNodes[i].className) {
		 		var _slideClasses = _this.wrapper.childNodes[i].className.split(' ')
		 		for (var j = 0; j < _slideClasses.length; j++) {
		 			if(_slideClasses[j]===params.slideClass) _this.slides.push(_this.wrapper.childNodes[i])
		 		};
		 	} 
		};
	  	for (var i = _this.slides.length - 1; i >= 0; i--) {
	  		_this._extendSwiperSlide(_this.slides[i]);
	  	};
	  	if (!oldNumber) return;
	  	if(oldNumber!=_this.slides.length && _this.createPagination) {
	  		// Number of slides has been changed
	  		_this.createPagination();
	  		_this.callPlugins('numberOfSlidesChanged')
	  	}
	  	/*
	  	if (_this.langDirection=='rtl') {
	  		for (var i = 0; i < _this.slides.length; i++) {
	  			_this.slides[i].style.float="right"
	  		};
	  	}
	  	*/
	}
	_this._calcSlides();

	//Create Slide
	_this.createSlide = function (html, slideClassList, el) {
	  	var slideClassList = slideClassList || _this.params.slideClass;
		var el = el||'div';
		var newSlide = document.createElement(el)
		newSlide.innerHTML = html||'';
		newSlide.className = slideClassList;
		return _this._extendSwiperSlide(newSlide);
	}

	//Append Slide  
	_this.appendSlide = function (html, slideClassList, el) {
		if (!html) return;
		if (html.nodeType) {
			return _this._extendSwiperSlide(html).append()
		}
		else {
			return _this.createSlide(html, slideClassList, el).append()
		}
	}
	_this.prependSlide = function (html, slideClassList, el) {
		if (!html) return;
		if (html.nodeType) {
			return _this._extendSwiperSlide(html).prepend()
		}
		else {
			return _this.createSlide(html, slideClassList, el).prepend()
		}
	}
	_this.insertSlideAfter = function (index, html, slideClassList, el) {
	  	if (!index) return false;
	  	if (index.nodeType) {
			return _this._extendSwiperSlide(index).insertAfter(index)
		}
		else {
			return _this.createSlide(html, slideClassList, el).insertAfter(index)
		}
	}
	_this.removeSlide = function (index) {
	  	if (_this.slides[index]) {
	  		_this.slides[index].remove()
	  		return true;
	  	}
	  	else return false;
	}
	_this.removeLastSlide = function () {
	  	if (_this.slides.length>0) {
	  		_this.slides[ (_this.slides.length-1) ].remove();
	  		return true
	  	}
	  	else {
	  		return false
	  	}
	}
	_this.removeAllSlides = function () {
	  	for (var i = _this.slides.length - 1; i >= 0; i--) {
	  		_this.slides[i].remove()
	  	};
	}
	_this.getSlide = function (index) {
	  	return _this.slides[index]
	}
	_this.getLastSlide = function () {
	  	return _this.slides[ _this.slides.length-1 ]
	}
	_this.getFirstSlide = function () {
	  	return _this.slides[0]
	}

	//Currently Active Slide
	_this.currentSlide = function () {
	  	return _this.slides[_this.activeSlide]
	}
	
	/*=========================
	  Find All Plugins
	  !!! Plugins API is in beta !!!
	  ===========================*/
	var _plugins = [];
	for (var plugin in _this.plugins) {
		if (params[plugin]) {
			var p = _this.plugins[plugin](_this, params[plugin])
			if (p)
				_plugins.push( p )	
		}
	}
	
	_this.callPlugins = function(method, args) {
		if (!args) args = {}
		for (var i=0; i<_plugins.length; i++) {
			if (method in _plugins[i]) {
				_plugins[i][method](args);
			}

		}
		
	}

	/*=========================
	  WP8 Fix
	  ===========================*/
	if (_this.ie10 && !params.onlyExternal) {
		if (isHorizontal) _this.wrapper.classList.add('swiper-wp8-horizontal')	
		else _this.wrapper.classList.add('swiper-wp8-vertical')	
	}
	
	/*=========================
	  Loop
	  ===========================*/
	if (params.loop) {
		(function(){
			numOfSlides = _this.slides.length
			var slideFirstHTML = '';
			var slideLastHTML = '';
			//Grab First Slides
			for (var i=0; i<params.slidesPerSlide; i++) {
				slideFirstHTML+=_this.slides[i].outerHTML
			}
			//Grab Last Slides
			for (var i=numOfSlides-params.slidesPerSlide; i<numOfSlides; i++) {
				slideLastHTML+=_this.slides[i].outerHTML
			}
			wrapper.innerHTML = slideLastHTML + wrapper.innerHTML + slideFirstHTML;
			_this._calcSlides()
			_this.callPlugins('onCreateLoop');
		})();
	}
	
	//Init Function
	var firstInit = false;

	_this.init = function(reInit) {
		var _width = window.getComputedStyle(_this.container, null).getPropertyValue('width')
		var _height = window.getComputedStyle(_this.container, null).getPropertyValue('height')
		var newWidth = parseInt(_width,10);
		var newHeight  = parseInt(_height,10);
		
		//IE8 Fixes
		if(isNaN(newWidth) || _this.ie8 && (_width.indexOf('%')>0)  ) {
			newWidth = _this.container.offsetWidth - parseInt(window.getComputedStyle(_this.container, null).getPropertyValue('padding-left'),10) - parseInt(window.getComputedStyle(_this.container, null).getPropertyValue('padding-right'),10) 
		}
		if(isNaN(newHeight) || _this.ie8 && (_height.indexOf('%')>0) ) {
			newHeight = _this.container.offsetHeight - parseInt(window.getComputedStyle(_this.container, null).getPropertyValue('padding-top'),10) - parseInt(window.getComputedStyle(_this.container, null).getPropertyValue('padding-bottom'),10) 		
		}
		
		if (!reInit) {
			if (_this.width==newWidth && _this.height==newHeight) return			
		}
		if (reInit || firstInit) {
			_this._calcSlides();
			if (params.pagination) {
				_this.updatePagination()
			}
		}
		_this.width  = newWidth;
		_this.height  = newHeight;
		
		var dividerVertical = isHorizontal ? 1 : params.slidesPerSlide,
			dividerHorizontal = isHorizontal ? params.slidesPerSlide : 1,
			slideWidth, slideHeight, wrapperWidth, wrapperHeight;

		numOfSlides = _this.slides.length
		if (!params.scrollContainer) {
			if (!_widthFromCSS) {
				slideWidth = _this.width/dividerHorizontal;
				slideHeight = _this.height/dividerVertical;	
			}
			else {
				slideWidth = _this.slides[0].offsetWidth;
				slideHeight = _this.slides[0].offsetHeight;
			}
			containerSize = isHorizontal ? _this.width : _this.height;
			slideSize = isHorizontal ? slideWidth : slideHeight;
			wrapperWidth = isHorizontal ? numOfSlides * slideWidth : _this.width;
			wrapperHeight = isHorizontal ? _this.height : numOfSlides*slideHeight;
			if (_widthFromCSS) {
				//Re-Calc sps for pagination
				params.slidesPerSlide = Math.round(containerSize/slideSize)
			}
		}
		else {
			//Unset dimensions in vertical scroll container mode to recalculate slides
			if (!isHorizontal) {
				wrapper.style.width='';
				wrapper.style.height='';
				_this.slides[0].style.width='';
				_this.slides[0].style.height='';
			}
			
			slideWidth = _this.slides[0].offsetWidth;
			slideHeight = _this.slides[0].offsetHeight;
			containerSize = isHorizontal ? _this.width : _this.height;
			
			slideSize = isHorizontal ? slideWidth : slideHeight;
			wrapperWidth = slideWidth;
			wrapperHeight = slideHeight;
		}

		wrapperSize = isHorizontal ? wrapperWidth : wrapperHeight;
	
		for (var i=0; i<_this.slides.length; i++ ) {
			var el = _this.slides[i];
			if (!_widthFromCSS) {
				el.style.width=slideWidth+"px"
				el.style.height=slideHeight+"px"
			}
			if (params.onSlideInitialize) {
				params.onSlideInitialize(_this, el);
			}
		}
		wrapper.style.width = wrapperWidth+"px";
		wrapper.style.height = wrapperHeight+"px";
		
		// Set Initial Slide Position	
		if(params.initialSlide > 0 && params.initialSlide < numOfSlides && !firstInit) {
			_this.realIndex = _this.activeSlide = params.initialSlide;
			
			if (params.loop) {
                _this.activeSlide = _this.realIndex-params.slidesPerSlide
            }
						
			if (isHorizontal) {
				_this.positions.current = -params.initialSlide * slideWidth;
				_this.setTransform( _this.positions.current, 0, 0);
			}
			else {	
				_this.positions.current = -params.initialSlide * slideHeight;
				_this.setTransform( 0, _this.positions.current, 0);
			}
		}
		
		// if (params.slidesPerSlide && params.slidesPerSlide > 1) {
		// 	slideSize = slideSize/params.slidesPerSlide	
		// }
		// slideSize = 150;
		if (!firstInit) _this.callPlugins('onFirstInit');
		else _this.callPlugins('onInit');
		
		firstInit = true;
	}
	_this.init()

	//ReInitizize function. Good to use after dynamically changes of Swiper, like after add/remove slides
	_this.reInit = function () {
	  	_this.init(true)
	}
	
	

	//Get Max And Min Positions
	function maxPos() {
		// var a = (wrapperSize - slideSize*params.slidesPerSlide);
		var a = (wrapperSize - containerSize);
		
		if (params.loop) a = a - containerSize;	
		if (params.scrollContainer) {
			a = slideSize - containerSize;
			if (a<0) a = 0;
		}
		if (params.slidesPerSlide > _this.slides.length) a = 0;
		return a;
	}
	function minPos() {
		var a = 0;
		if (params.loop) a = containerSize;
		return a;	
	}
	
	/*=========================
	  Pagination
	  ===========================*/
	_this.updatePagination = function() {
		if (_this.slides.length<2) return;
		var activeSwitch = dQ(params.pagination+' .'+params.paginationActiveClass)
		if(!activeSwitch) return
		for (var i=0; i < activeSwitch.length; i++) {
			if (activeSwitch.item(i).className.indexOf('active')>=0) {
				activeSwitch.item(i).className = params.paginationClass
			}	
		}
		var pagers = dQ(params.pagination+' .'+params.paginationClass).length;
		var minPagerIndex = params.loop ? _this.realIndex-params.slidesPerSlide : _this.realIndex;
		var maxPagerIndex = minPagerIndex + (params.slidesPerSlide-1);
		for (var i = minPagerIndex; i <= maxPagerIndex; i++ ) {
			var j = i;
			if (j>=pagers) j=j-pagers;
			if (j<0) j = pagers + j;
			if (j<numOfSlides) {
				dQ(params.pagination+' .'+params.paginationClass).item( j ).className = params.paginationClass+' '+params.paginationActiveClass
			}
			if (i==minPagerIndex) dQ(params.pagination+' .'+params.paginationClass).item( j ).className+=' swiper-activeslide-switch'
		}
		
	}
	_this.createPagination = function () {
	  	if (params.pagination && params.createPagination) {
			var paginationHTML = "";
			var numOfSlides = _this.slides.length;
			var numOfButtons = params.loop ? numOfSlides - params.slidesPerSlide*2 : numOfSlides;
			for (var i = 0; i < numOfButtons; i++) {
				paginationHTML += '<span class="'+params.paginationClass+'"></span>'
			}
			dQ(params.pagination)[0].innerHTML = paginationHTML
			//setTimeout(function(){
				_this.updatePagination()
			//},0)
			
			_this.callPlugins('onCreatePagination');
		}	
	}
	_this.createPagination();
	
	
	//Window Resize Re-init
	_this.resizeEvent = ('onorientationchange' in window) ? 'orientationchange' : 'resize';
	_this.resizeFix = function(){
		_this.callPlugins('beforeResizeFix');
		_this.init()
		//To fix translate value
		if (!params.scrollContainer) 
			_this.swipeTo(_this.activeSlide, 0, false)
		else {
			var pos = isHorizontal ? _this.getTranslate('x') : _this.getTranslate('y')
			if (pos < -maxPos()) {
				var x = isHorizontal ? -maxPos() : 0;
				var y = isHorizontal ? 0 : -maxPos();
				_this.setTransition(0)
				_this.setTransform(x,y,0)	
			}
		}
		_this.callPlugins('afterResizeFix');
	}
	if (!params.disableAutoResize) {
		//Check for resize event
		window.addEventListener(_this.resizeEvent, _this.resizeFix, false)
	}

	/*========================================== 
		Autoplay 
	============================================*/

	var autoPlay
	_this.startAutoPlay = function() {
		if (params.autoPlay && !params.loop) {
			autoPlay = setInterval(function(){
				var newSlide = _this.realIndex + 1
				if ( newSlide == numOfSlides) newSlide = 0 
				_this.swipeTo(newSlide) 
			}, params.autoPlay)
		}
		else if (params.autoPlay && params.loop) {
			autoPlay = setInterval(function(){
				_this.swipeNext()
			}, params.autoPlay)
		}
		_this.callPlugins('onAutoPlayStart');
	}
	_this.stopAutoPlay = function() {
		if (autoPlay)
			clearInterval(autoPlay)
		_this.callPlugins('onAutoPlayStop');
	}
	if (params.autoPlay) {
		_this.startAutoPlay()
	}
	
	/*========================================== 
		Event Listeners 
	============================================*/
	wrapper.addEventListener(_this.touchEvents.touchStart, onTouchStart, false);
	
	//Mouse 'mousemove' and 'mouseup' events should be assigned to document
	var lestenEl = (_this.support.touch) ? wrapper : document

	lestenEl.addEventListener(_this.touchEvents.touchMove, onTouchMove, false);
	lestenEl.addEventListener(_this.touchEvents.touchEnd, onTouchEnd, false);
	
	//Remove Events
	_this.destroy = function(removeResizeFix){
		removeResizeFix = removeResizeFix===false ? removeResizeFix : removeResizeFix || true
		if (removeResizeFix) {
			window.removeEventListener(_this.resizeEvent, _this.resizeFix, false);
		}
		wrapper.removeEventListener(_this.touchEvents.touchStart, onTouchStart, false);
		lestenEl.removeEventListener(_this.touchEvents.touchMove, onTouchMove, false);
		lestenEl.removeEventListener(_this.touchEvents.touchEnd, onTouchEnd, false);
		if (params.keyboardControl) {
			document.removeEventListener('keydown', handleKeyboardKeys, false);
		}
		if (params.mousewheelControl && _this._wheelEvent) {
			document.removeEventListener(_this._wheelEvent, handleMousewheel, false);
		}

		_this.callPlugins('onDestroy');
	}
	/*=========================
	  Prevent Links
	  ===========================*/

	_this.allowLinks = true;
	if (params.preventLinks) {
		var links = _this.container.querySelectorAll('a')
		for (var i=0; i<links.length; i++) {
			links[i].addEventListener('click', preventClick, false)	
		}
	}
	function preventClick(e) {
		if (!_this.allowLinks) e.preventDefault();	
	}

	/*========================================== 
		Keyboard Control 
	============================================*/
	if (params.keyboardControl) {
		function handleKeyboardKeys (e) {
			var kc = e.keyCode || e.charCode;
			if (isHorizontal) {
				if (kc==37 || kc==39) e.preventDefault();
				if (kc == 39) _this.swipeNext()
				if (kc == 37) _this.swipePrev()
			}
			else {
				if (kc==38 || kc==40) e.preventDefault();
				if (kc == 40) _this.swipeNext()
				if (kc == 38) _this.swipePrev()
			}
		}
		document.addEventListener('keydown',handleKeyboardKeys, false);
		
		
	}

	/*========================================== 
		Mousewheel Control. Beta! 
	============================================*/
	// detect available wheel event
    _this._wheelEvent = false;
	
	if (params.mousewheelControl) {
		if ( document.onmousewheel !== undefined ) {
	        _this._wheelEvent = "mousewheel"
	    }
	    try {
	        WheelEvent("wheel");
	        _this._wheelEvent = "wheel";
	    } catch (e) {}
	    if ( !_this._wheelEvent ) {
			_this._wheelEvent = "DOMMouseScroll";
	    }
		function handleMousewheel (e) {
			var we = _this._wheelEvent;
			var delta;
			if (we == 'mousewheel') delta = e.wheelDelta; 
			if (we == 'DOMMouseScroll') delta = -e.detail;
			if (we == 'wheel') delta = Math.abs(e.deltaX)>Math.abs(e.deltaY) ? - e.deltaX : - e.deltaY;

			if(delta<0) _this.swipeNext()
			else _this.swipePrev()

			e.preventDefault();
			return false;
		}
		if (_this._wheelEvent) {
			_this.container.addEventListener(_this._wheelEvent, handleMousewheel, false);
		}
	}
	/*=========================
	  Handle Touches
	  ===========================*/
	function onTouchStart(event) {
		
		//Exit if slider is already was touched
		if (_this.isTouched || params.onlyExternal) {
			return false
		}
		
		//Check For Nested Swipers
		
		_this.isTouched = true;
		
		if (!_this.support.touch || event.targetTouches.length == 1 ) {
			_this.callPlugins('onTouchStartBegin');
			
			if (params.loop) _this.fixLoop();
			if(!_this.support.touch) {
				if(event.preventDefault) event.preventDefault();
				else event.returnValue = false;
			}
			var pageX = _this.support.touch ? event.targetTouches[0].pageX : (event.pageX || event.clientX)
			var pageY = _this.support.touch ? event.targetTouches[0].pageY : (event.pageY || event.clientY)
			
			//Start Touches to check the scrolling
			_this.touches.startX = _this.touches.currentX = pageX;
			_this.touches.startY = _this.touches.currentY = pageY;
			
			_this.touches.start = _this.touches.current = isHorizontal ? _this.touches.startX : _this.touches.startY ;
			
			//Set Transition Time to 0
			_this.setTransition(0)
			
			//Get Start Translate Position
			_this.positions.start = _this.positions.current = isHorizontal ? _this.getTranslate('x') : _this.getTranslate('y');
			
			//Set Transform
			if (isHorizontal) {
				_this.setTransform( _this.positions.start, 0, 0)
			}
			else {
				_this.setTransform( 0, _this.positions.start, 0)
			}
			
			//TouchStartTime
			var tst = new Date()
			_this.times.start = tst.getTime()
			
			//Unset Scrolling
			isScrolling = undefined;
			
			//Define Clicked Slide without additional event listeners
			if (params.onSlideClick || params.onSlideTouch) {
				;(function () {
					var el = _this.container;
					var box = el.getBoundingClientRect();
					var body = document.body;
					clientTop  = el.clientTop  || body.clientTop  || 0;
					clientLeft = el.clientLeft || body.clientLeft || 0;
					scrollTop  = window.pageYOffset || el.scrollTop;
					scrollLeft = window.pageXOffset || el.scrollLeft;
					var x = pageX - box.left + clientLeft - scrollLeft;
					var y = pageY - box.top - clientTop - scrollTop;
				  	var touchOffset = isHorizontal ? x : y;	
				  	var beforeSlides = -Math.round(_this.positions.current/slideSize)
				  	var clickedIndex = Math.floor(touchOffset/slideSize) + beforeSlides
				  	if (params.loop) {
				  		clickedIndex -= params.slidesPerSlide;
				  		if (clickedIndex<0) {
				  			clickedIndex = _this.slides.length+clickedIndex-(params.slidesPerSlide*2);
				  		}
				  	}
				  	_this.clickedSlideIndex = clickedIndex
				  	_this.clickedSlide = _this.getSlide(clickedIndex);
				  	if (params.onSlideTouch) {
				  		params.onSlideTouch(_this);
				  		_this.callPlugins('onSlideTouch');
				  	}
				})();
			}

			//CallBack
			if (params.onTouchStart) params.onTouchStart(_this)
			_this.callPlugins('onTouchStartEnd');
			
		}
	}
	function onTouchMove(event) {
		
		// If slider is not touched - exit
		if (!_this.isTouched || params.onlyExternal) return
		
		var pageX = _this.support.touch ? event.targetTouches[0].pageX : (event.pageX || event.clientX)
		var pageY = _this.support.touch ? event.targetTouches[0].pageY : (event.pageY || event.clientY)
		//check for scrolling
		
		if ( typeof isScrolling == 'undefined' && isHorizontal) {
		  isScrolling = !!( isScrolling || Math.abs(pageY - _this.touches.startY) > Math.abs( pageX - _this.touches.startX ) )
		}
		if ( typeof isScrolling == 'undefined' && !isHorizontal) {
		  isScrolling = !!( isScrolling || Math.abs(pageY - _this.touches.startY) < Math.abs( pageX - _this.touches.startX ) )
		}
		if (isScrolling ) {
			_this.isTouched = false;
			return
		}
		
		//Check For Nested Swipers
		if (event.assignedToSwiper) {
			_this.isTouched = false;
			return
		}
		event.assignedToSwiper = true;	
		
		//Block inner links
		if (params.preventLinks) {
			_this.allowLinks = false;	
		}
		
		//Stop AutoPlay if exist
		if (params.autoPlay) {
			_this.stopAutoPlay()
		}
		
		if (!_this.support.touch || event.touches.length == 1) {
			
			_this.callPlugins('onTouchMoveStart');

			if(event.preventDefault) event.preventDefault();
			else event.returnValue = false;
			
			_this.touches.current = isHorizontal ? pageX : pageY ;
			
			_this.positions.current = (_this.touches.current - _this.touches.start)*params.ratio + _this.positions.start			
			
			if (params.resistance) {
				//Resistance for Negative-Back sliding
				if(_this.positions.current > 0 && !(params.freeMode&&!params.freeModeFluid)) {
					
					if (params.loop) {
						var resistance = 1;
						if (_this.positions.current>0) _this.positions.current = 0;
					}
					else {
						var resistance = (containerSize*2-_this.positions.current)/containerSize/2;
					}
					if (resistance < 0.5) 
						_this.positions.current = (containerSize/2)
					else 
						_this.positions.current = _this.positions.current * resistance
					
				}
				//Resistance for After-End Sliding
				if ( (_this.positions.current) < -maxPos() && !(params.freeMode&&!params.freeModeFluid)) {
					
					if (params.loop) {
						var resistance = 1;
						var newPos = _this.positions.current
						var stopPos = -maxPos() - containerSize
					}
					else {
						
						var diff = (_this.touches.current - _this.touches.start)*params.ratio + (maxPos()+_this.positions.start)
						var resistance = (containerSize+diff)/(containerSize);
						var newPos = _this.positions.current-diff*(1-resistance)/2
						var stopPos = -maxPos() - containerSize/2;
					}
					
					if (newPos < stopPos || resistance<=0)
						_this.positions.current = stopPos;
					else 
						_this.positions.current = newPos
				}
			}
			
			//Move Slides
			if (!params.followFinger) return
			if (isHorizontal) _this.setTransform( _this.positions.current, 0, 0)
			else _this.setTransform( 0, _this.positions.current, 0)
			
			if (params.freeMode) {
				_this.updateActiveSlide(_this.positions.current)
			}

			//Prevent onSlideClick Fallback if slide is moved
			if (params.onSlideClick && _this.clickedSlide) {
				_this.clickedSlide = false
			}

			//Callbacks
			if (params.onTouchMove) params.onTouchMove(_this)
			_this.callPlugins('onTouchMoveEnd');
			
			return false
		}
	}
	function onTouchEnd(event) {

		// If slider is not touched exit
		if ( params.onlyExternal || !_this.isTouched ) return
		_this.isTouched = false
		
		//Release inner links
		if (params.preventLinks) {
			setTimeout(function(){
				_this.allowLinks = true;	
			},10)
		}

		//onSlideClick
		if (params.onSlideClick && _this.clickedSlide) {
			params.onSlideClick(_this);
			_this.callPlugins('onSlideClick')
		}

		//Check for Current Position
		if (!_this.positions.current && _this.positions.current!==0) {
			_this.positions.current = _this.positions.start	
		}
		
		//For case if slider touched but not moved
		if (isHorizontal) _this.setTransform( _this.positions.current, 0, 0)
		else _this.setTransform( 0, _this.positions.current, 0)
		//--
		
		// TouchEndTime
		var tet = new Date()
		_this.times.end = tet.getTime();
		
		//Difference
		_this.touches.diff = _this.touches.current - _this.touches.start		
		_this.touches.abs = Math.abs(_this.touches.diff)
		
		_this.positions.diff = _this.positions.current - _this.positions.start
		_this.positions.abs = Math.abs(_this.positions.diff)
		
		var diff = _this.positions.diff ;
		var diffAbs =_this.positions.abs ;

		if(diffAbs < 5) {
			_this.swipeReset()
		}
		
		var maxPosition = wrapperSize - slideSize*params.slidesPerSlide;
		if (params.scrollContainer) {
			maxPosition = slideSize	- containerSize
		}
		
		//Prevent Negative Back Sliding
		if (_this.positions.current > 0) {
			_this.swipeReset()
			if (params.onTouchEnd) params.onTouchEnd(_this)
			_this.callPlugins('onTouchEnd');
			return
		}
		//Prevent After-End Sliding
		if (_this.positions.current < -maxPosition) {
			_this.swipeReset()
			if (params.onTouchEnd) params.onTouchEnd(_this)
			_this.callPlugins('onTouchEnd');
			return
		}
		
		//Free Mode
		if (params.freeMode) {
			if ( (_this.times.end - _this.times.start) < 300 && params.freeModeFluid ) {
				var newPosition = _this.positions.current + _this.touches.diff * 2 ;
				if (newPosition < maxPosition*(-1)) newPosition = -maxPosition;
				if (newPosition > 0) newPosition = 0;
				if (isHorizontal)
					_this.setTransform( newPosition, 0, 0)
				else 
					_this.setTransform( 0, newPosition, 0)
					
				_this.setTransition( (_this.times.end - _this.times.start)*2 )
				_this.updateActiveSlide(newPosition)
			}
			if (!params.freeModeFluid || (_this.times.end - _this.times.start) >= 300) _this.updateActiveSlide(_this.positions.current)
			if (params.onTouchEnd) params.onTouchEnd(_this)
			_this.callPlugins('onTouchEnd');
			return
		}
		
		//Direction
		direction = diff < 0 ? "toNext" : "toPrev"
		
		//Short Touches
		if (direction=="toNext" && ( _this.times.end - _this.times.start <= 300 ) ) {
			if (diffAbs < 30) _this.swipeReset()
			else _this.swipeNext(true);
		}
		
		if (direction=="toPrev" && ( _this.times.end - _this.times.start <= 300 ) ) {
		
			if (diffAbs < 30) _this.swipeReset()
			else _this.swipePrev(true);
		}
		
		//Long Touches
		if (direction=="toNext" && ( _this.times.end - _this.times.start > 300 ) ) {
			if (diffAbs >= slideSize*0.5) {
				_this.swipeNext(true);
			}
			else {
				_this.swipeReset()
			}
		}
		if (direction=="toPrev" && ( _this.times.end - _this.times.start > 300 ) ) {
			if (diffAbs >= slideSize*0.5) {
				_this.swipePrev(true);
			}
			else {
				_this.swipeReset()
			}
		}
		if (params.onTouchEnd) params.onTouchEnd(_this)
		_this.callPlugins('onTouchEnd');
	}
	
	/*=========================
	  Swipe Functions
	  ===========================*/
	_this.swipeNext = function(internal) {
		if (!internal&&params.loop) _this.fixLoop();
		
		_this.callPlugins('onSwipeNext');

		var getTranslate = isHorizontal ? _this.getTranslate('x') : _this.getTranslate('y')
		var newPosition = Math.floor(Math.abs(getTranslate)/Math.floor(slideSize))*slideSize + slideSize 
		var curPos = Math.abs(getTranslate)
		if (newPosition==wrapperSize) return;
		if (curPos >= maxPos() && !params.loop) return;
		if (newPosition > maxPos() && !params.loop) {
			newPosition = maxPos()
		};
		if (params.loop) {
			if (newPosition >= (maxPos()+containerSize)) newPosition = maxPos()+containerSize
		}
		if (isHorizontal) {
			_this.setTransform(-newPosition,0,0)
		}
		else {
			_this.setTransform(0,-newPosition,0)
		}
		
		_this.setTransition( params.speed)
		
		//Update Active Slide
		_this.updateActiveSlide(-newPosition)
		
		//Run Callbacks
		slideChangeCallbacks()
		
		return true
	}
	
	_this.swipePrev = function(internal) {
		
		if (!internal&&params.loop) _this.fixLoop();

		_this.callPlugins('onSwipePrev');

		var getTranslate = isHorizontal ? _this.getTranslate('x') : _this.getTranslate('y')
		
		var newPosition = (Math.ceil(-getTranslate/slideSize)-1)*slideSize;
		
		if (newPosition < 0) newPosition = 0;
		
		if (isHorizontal) {
			_this.setTransform(-newPosition,0,0)
		}
		else  {
			_this.setTransform(0,-newPosition,0)
		}		
		_this.setTransition(params.speed)
		
		//Update Active Slide
		_this.updateActiveSlide(-newPosition)
		
		//Run Callbacks
		slideChangeCallbacks()
		
		return true
	}
	
	_this.swipeReset = function(prevention) {
		_this.callPlugins('onSwipeReset');

		var getTranslate = isHorizontal ? _this.getTranslate('x') : _this.getTranslate('y');
		var newPosition = getTranslate<0 ? Math.round(getTranslate/slideSize)*slideSize : 0
		var maxPosition = -maxPos()
		if (params.scrollContainer)  {
			newPosition = getTranslate<0 ? getTranslate : 0;
			maxPosition = containerSize - slideSize;
		}
		
		if (newPosition <= maxPosition) {
			newPosition = maxPosition
		}
		if (params.scrollContainer && (containerSize>slideSize)) {
			newPosition = 0;
		}
		
		if (params.mode=='horizontal') {
			_this.setTransform(newPosition,0,0)
		}
		else {
			_this.setTransform(0,newPosition,0)
		}
		
		_this.setTransition( params.speed)
		
		//Update Active Slide
		_this.updateActiveSlide(newPosition)
		
		//Reset Callback
		if (params.onSlideReset) {
			params.onSlideReset(_this)
		}
		
		return true
	}
	
	var firstTimeLoopPositioning = true;
	
	_this.swipeTo = function (index, speed, runCallbacks) {	
	
		index = parseInt(index, 10); //type cast to int
		_this.callPlugins('onSwipeTo', {index:index, speed:speed});
			
		if (index > (numOfSlides-1)) return;
		if (index<0 && !params.loop) return;
		runCallbacks = runCallbacks===false ? false : runCallbacks || true
		var speed = speed===0 ? speed : speed || params.speed;
		
		if (params.loop) index = index + params.slidesPerSlide;
		
		if (index > numOfSlides - params.slidesPerSlide) index = numOfSlides - params.slidesPerSlide;
		var newPosition =  -index*slideSize ;
		
		if(firstTimeLoopPositioning && params.loop && params.initialSlide > 0 && params.initialSlide < numOfSlides){
			newPosition = newPosition - params.initialSlide * slideSize;
			firstTimeLoopPositioning = false;
		}
		
		if (isHorizontal) {
			_this.setTransform(newPosition,0,0)
		}
		else {
			_this.setTransform(0,newPosition,0)
		}
		_this.setTransition( speed )	
		_this.updateActiveSlide(newPosition)

		//Run Callbacks
		if (runCallbacks) 
			slideChangeCallbacks()
			
        return true
	}
	
	function slideChangeCallbacks() {
		//Transition Start Callback
		_this.callPlugins('onSlideChangeStart');
		if (params.onSlideChangeStart) {
			params.onSlideChangeStart(_this)
		}
		
		//Transition End Callback
		if (params.onSlideChangeEnd) {
			_this.transitionEnd(params.onSlideChangeEnd)
		}
		
	}
	
	_this.updateActiveSlide = function(position) {
        _this.previousSlide = _this.realIndex
		_this.realIndex = Math.round(-position/slideSize)
		if (!params.loop) _this.activeSlide = _this.realIndex;
		else {
			_this.activeSlide = _this.realIndex-params.slidesPerSlide
			if (_this.activeSlide>=numOfSlides-params.slidesPerSlide*2) {
				_this.activeSlide = numOfSlides - params.slidesPerSlide*2 - _this.activeSlide
			}
			if (_this.activeSlide<0) {
				_this.activeSlide = numOfSlides - params.slidesPerSlide*2 + _this.activeSlide	
			}
		}
		if (_this.realIndex==numOfSlides) _this.realIndex = numOfSlides-1
		if (_this.realIndex<0) _this.realIndex = 0

		//Update Pagination
		if (params.pagination) {
			_this.updatePagination()
		}
		
	}
	
	
	
	/*=========================
	  Loop Fixes
	  ===========================*/
	_this.fixLoop = function(){		
		//Fix For Negative Oversliding
		if (_this.realIndex < params.slidesPerSlide) {
			var newIndex = numOfSlides - params.slidesPerSlide*3 + _this.realIndex;
			_this.swipeTo(newIndex,0, false)
		}
		//Fix For Positive Oversliding
		if (_this.realIndex > numOfSlides - params.slidesPerSlide*2) {
			var newIndex = -numOfSlides + _this.realIndex + params.slidesPerSlide
			_this.swipeTo(newIndex,0, false)
		}
	}
	if (params.loop) {
		_this.swipeTo(0,0, false)
	}

	

}

Swiper.prototype = {
	plugins : {},
	//Transition End
	transitionEnd : function(callback) {
		var a = this
		var el = a.wrapper
		var events = ['webkitTransitionEnd','transitionend', 'oTransitionEnd', 'MSTransitionEnd', 'msTransitionEnd'];
		if (callback) {
			function fireCallBack() {
				callback(a)
				for (var i=0; i<events.length; i++) {
					el.removeEventListener(events[i], fireCallBack, false)
				}
			}
			for (var i=0; i<events.length; i++) {
				el.addEventListener(events[i], fireCallBack, false)
			}
		}
	},
	
	//Touch Support
	isSupportTouch : function() {
		return ("ontouchstart" in window) || window.DocumentTouch && document instanceof DocumentTouch;
	},
		
	// 3D Transforms Test 
	isSupport3D : function() {
		var div = document.createElement('div');
		div.id = 'test3d';
			
		var s3d=false;	
		if("webkitPerspective" in div.style) s3d=true;
		if("MozPerspective" in div.style) s3d=true;
		if("OPerspective" in div.style) s3d=true;
		if("MsPerspective" in div.style) s3d=true;
		if("perspective" in div.style) s3d=true;

		/* Test with Media query for Webkit to prevent FALSE positive*/	
		if(s3d && ("webkitPerspective" in div.style) ) {
			var st = document.createElement('style');
			st.textContent = '@media (-webkit-transform-3d), (transform-3d), (-moz-transform-3d), (-o-transform-3d), (-ms-transform-3d) {#test3d{height:5px}}'
			document.getElementsByTagName('head')[0].appendChild(st);
			document.body.appendChild(div);
			s3d = div.offsetHeight === 5;
			st.parentNode.removeChild(st);
			div.parentNode.removeChild(div);
		}
		
		return s3d;
	},
		
	//GetTranslate
	getTranslate : function(axis){
		var el = this.wrapper
		var matrix;
		var curTransform;
		if (window.WebKitCSSMatrix) {
			var transformMatrix = new WebKitCSSMatrix(window.getComputedStyle(el, null).webkitTransform)
			matrix = transformMatrix.toString().split(',');
		}
		else {
			var transformMatrix = 	window.getComputedStyle(el, null).MozTransform || window.getComputedStyle(el, null).OTransform || window.getComputedStyle(el, null).MsTransform || window.getComputedStyle(el, null).msTransform  || window.getComputedStyle(el, null).transform|| window.getComputedStyle(el, null).getPropertyValue("transform").replace("translate(", "matrix(1, 0, 0, 1,");
			matrix = transformMatrix.toString().split(',');
			
		}
		if (axis=='x') {
			//Crazy IE10 Matrix
			if (matrix.length==16) 
				curTransform = parseInt( matrix[12], 10 )
			//Normal Browsers
			else 
				curTransform = parseInt( matrix[4], 10 )
				
		}
		
		if (axis=='y') {
			//Crazy IE10 Matrix
			if (matrix.length==16) 
				curTransform = parseInt( matrix[13], 10 )
			//Normal Browsers
			else 
				curTransform = parseInt( matrix[5], 10 )
		}
		
		return curTransform;
	},
	
	//Set Transform
	setTransform : function(x,y,z) {
		
		var es = this.wrapper.style
		x=x||0;
		y=y||0;
		z=z||0;
		if (this.support.threeD) {
			es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = 'translate3d('+x+'px, '+y+'px, '+z+'px)'
		}
		else {
			
			es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = 'translate('+x+'px, '+y+'px)'
			if (this.ie8) {
				es.left = x+'px'
				es.top = y+'px'
			}
		}
		this.callPlugins('onSetTransform', {x:x, y:y, z:z})
	},
	
	//Set Transition
	setTransition : function(duration) {
		var es = this.wrapper.style
		es.webkitTransitionDuration = es.MsTransitionDuration = es.msTransitionDuration = es.MozTransitionDuration = es.OTransitionDuration = es.transitionDuration = duration/1000+'s';
		this.callPlugins('onSetTransition', {duration: duration})
	},
	
	//Check for IE8
	ie8: (function(){
		var rv = -1; // Return value assumes failure.
		if (navigator.appName == 'Microsoft Internet Explorer') {
			var ua = navigator.userAgent;
			var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
			if (re.exec(ua) != null)
				rv = parseFloat(RegExp.$1);
		}
		return rv != -1 && rv < 9;
	})(),
	
	ie10 : window.navigator.msPointerEnabled
}

/*=========================
  jQuery & Zepto Plugins
  ===========================*/	  
if (window.jQuery||window.Zepto) {
	(function($){
		$.fn.swiper = function(params) {
			var s = new Swiper($(this)[0], params)
			$(this).data('swiper',s);
			return s
		}
	})(window.jQuery||window.Zepto)
}
