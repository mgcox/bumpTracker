import imageio
import sys

# with imageio.get_writer('images/results/movie.gif', mode='i') as writer:

filename = sys.argv[1] 
count = int(sys.argv[2])

frames = [ ]

for i in range(0,count):
    image = imageio.imread(filename+str(i)+".jpeg")
    frames.append(image)
    print("added " + filename+str(i)+".jpeg")


exportname = "output.gif"
kargs = { 'duration': 0.5 }
imageio.mimsave(exportname, frames, 'GIF', **kargs)
