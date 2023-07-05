import pyglet
from pyglet.window import mouse, key
import time
import os, sys

search_directory = sys.argv[1]
if not os.path.isdir(search_directory):
	print("{} is not a folder".format(search_directory))
sleepfor = 1
counter = 0

def sleep_m(by):
	global sleepfor
	if sleepfor + by < 0:
		#can't do that, so
		pass
	else:
		sleepfor += by
		
def on_mouse_press(x, y, button, modifiers):
	if button == mouse.LEFT:
		#sleepfor = sleepfor + 1;
		pass
	elif button == mouse.RIGHT and sleepfor != 0:
		#sleepfor = sleepfor - 1;
		pass
	else:
		sys.exit()
	win.on_key_press = on_key_press

def on_key_press(symbol, modifiers):
	if symbol == key.ESCAPE:
		sys.exit()
	elif symbol == key.DOWN:
		sleep_m(-1)
	elif symbol == key.UP:
		sleep_m(1)
	win.on_key_press = on_key_press
	
win = pyglet.window.Window(fullscreen=True);
win.set_caption("Image Viewer")
win.on_mouse_press = on_mouse_press
win.on_key_press = on_key_press
width, height = win.get_size()

ft = pyglet.font.load('Arial', 36)
num_imgs = 0
#count
for root, dirs, files in os.walk(search_directory):
		for file in files:
			if file.endswith(".jpg") or file.endswith(".png"):
				num_imgs += 1
				print("#",num_imgs," ",root,file)

#main execution loop				
while not win.has_exit:
	for root, dirs, files in os.walk(search_directory):
		for file in files:
			if file.endswith(".jpg") or file.endswith(".png"):
				img = pyglet.image.load(os.path.join(root,file))
				print(img)
				if counter == num_imgs:
					counter = 0
				counter += 1

				#handle text
				text = pyglet.text.Label("Image: " + str(counter) + "/" + str(num_imgs), x=0, y=height-36)
				wait_text = pyglet.text.Label("Wait: " + str(sleepfor) + " second(s)", x=0, y=height-72)
				
				win.dispatch_events()
				win.clear()
				text.draw()
				wait_text.draw()

				img.anchor_x = img.width // 2
				img.anchor_y = img.height // 2

				img.blit(width / 2, height / 2)

				win.flip()
				time.sleep(sleepfor)
				
