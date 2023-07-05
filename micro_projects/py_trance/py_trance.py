from pyglet import window
from pyglet import image
from pyglet import clock
import random
from pyglet.gl import *
from pyglet.window import mouse, key
import sys, os

##----- CLASSES -----##

class py_trance(object):
    """The visualizer object object."""
    def __init__(self):
        self.animations = []
        self.window_object = window.Window(400, 400)#fullscreen = True)
        self.window_object.set_caption("PyTrance")
        self.window_object.on_key_press = self.on_key_press
        
    def quit(self):
        sys.exit()
        
    def on_key_press(self, symbol, modifiers):
        if symbol == key.ESCAPE:
            quit()
        elif symbol == key.RETURN:
            self.add_ball()
        elif symbol == key.BACKSPACE:
            if self.animations:
                del self.animations[-1]
        self.window_object.on_key_press = self.on_key_press
        
    def add_animation(self, animation):
        self.animations.append(animation)
    
    def remove_aniation(self, anmiation):
        pass
        
    def draw(self, dt):
        point = Point(200, 200)
        for animation in self.animations:
            animation.update(dt)
            
    def add_ball(self):
        PKG = os.path.dirname(__file__)
        BALL_IMAGE = os.path.join(PKG, 'ball.png')
        ball_image = image.load(BALL_IMAGE)
        self.temp = (random.random() - 0.5)*1000 #shit needs the same dx/dy
        self.add_animation(Animation(200, 200,
       self.temp, self.temp, ball_image, 0.5))

class Point(object):
    def __init__(self, x, y):
        self.x = x
        self.y = y
        
    def get_cords(self):
        return self.x, self.y
        
class Animation(object):
    def __init__(self, x, y, dx, dy, images, period):
        self.x = x
        self.y = y
        self.dx = dx
        self.dy = dy
        self.images = images
        self.period = period
        self.time = 0
        self.frame = 0
        self.finished = False

    def update_circle(self, dt, point):
        self.frame += 1
        self.px, self.py = point.get_cords()
        print(self.px, self.py)
        if self.y <= self.py:
            if self.dx > 0:
                self.dx *= -1
        elif self.y >= self.py:
            if self.dx > 0:
                self.dx *= -1
        
        if self.x <= self.px:
            if self.dy > 0:
                self.dy *= -1
        elif self.x >= self.px:
            if self.dy < 0:
                self.dy *= -1
                
        self.x += self.dx * dt
        self.y += self.dy * dt
       # print "frame:", self.frame, "dx:", self.dx, "dy:", self.dy      
        self.time += dt
        self.draw()
          
    def update(self, dt):
        self.frame += 1
        
        if self.x+32 >= 400:
            self.x = 399-32
            self.dx *= -1
            
        if self.x <= 0:
            self.x = 1  
            self.dx *= -1
                  
        if self.y+32 >= 400:
            self.y = 399-32
            self.dy *= -1
            
        if self.y <= 0:
            self.y = 1
            self.dy *= -1
                    
        self.dy -= 5.0
        print("frame:", self.frame, "dx:", self.dx, "dy:", self.dy)
        self.x += self.dx * dt
        self.y += self.dy * dt
        self.time += dt
        self.draw()
            #if self.frame == len(self.images):
            #    self.frame = 0 
            #    self.finished = True

    def draw(self):
        self.images.blit(self.x, self.y, 0)
       #img.blit(self.x - img.width / 2, self.y - img.height / 2, 0)

#class Sphere(Animation):
#    def __init__(self, x, y, dx, dy, images, period):
 #       super()
 
##----- GAME -----##
visul = py_trance()
PKG = os.path.dirname(__file__)
BALL_IMAGE = os.path.join(PKG, 'ball.png')
ball_image = image.load(BALL_IMAGE)
visul.add_animation(Animation(100, 100, (random.random()-0.5)*100, (random.random()-0.5)*100, ball_image, 0.5))
#run loop
while not visul.window_object.has_exit:
    dt = clock.tick()
    visul.window_object.dispatch_events()
    visul.window_object.clear()
    visul.draw(dt)
    visul.window_object.flip()