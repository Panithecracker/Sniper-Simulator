
import math
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import matplotlib.image as mpimg
import random
import pygame

#Rifle object:
class Rifle:
    def __init__(self,L1,L2,h,theta_rad): #default constructor
        self.A = (0,0)
        self.B = (L1 * math.cos(theta_rad), L1 * math.sin(theta_rad))
        self.C = (h * math.cos(np.pi / 2 + theta_rad), h * math.sin(np.pi / 2 + theta_rad))
        theta_aux = math.atan(h / L2) + theta_rad
        r_aux = math.sqrt(h ** 2 + L2 ** 2)
        self.D = (r_aux * math.cos(theta_aux), r_aux * math.sin(theta_aux))
        self.E = (0.5 * L1 * math.cos(np.pi + theta_rad), 0.5 * L1 * math.sin(np.pi + theta_rad))
        self.F = (-0.25*L1,-0.375*L1)
        self.G = (0.25*L1,-0.375*L1)
        self.H = (L2 * math.cos(theta_rad), L2 * math.sin(theta_rad))
        self.body_length = L1
        self.scope_length = L2
        self.scope_height = h
        self.shooting_angle = theta_rad % (2*math.pi)

    def Rotate(self,theta): #rotate the rifle by theta radians
        R_aux = Rifle(self.body_length,self.scope_length,self.scope_height,self.shooting_angle+theta)
        self.A =R_aux.A
        self.B = R_aux.B
        self.C = R_aux.C
        self.D = R_aux.D
        self.E = R_aux.E
        self.F = R_aux.F
        self.G = R_aux.G
        self.H = R_aux.H
        self.shooting_angle = R_aux.shooting_angle #before it was self.shooting_angle += theta
    def DrawRifle(self,b,s,ls,rs,bl,br):
        #arguments : line plots from the same axes object used to hold the plots of different parts of the rifle mesh
        #draw on the landscape scale axes :
        b.set_data([self.E[0], self.B[0]], [self.E[1], self.B[1]])
        s.set_data([self.C[0], self.D[0]], [self.C[1], self.D[1]])
        ls.set_data([self.A[0], self.C[0]], [self.A[1], self.C[1]])
        rs.set_data([self.H[0], self.D[0]], [self.H[1], self.D[1]])
        bl.set_data([self.F[0], 0], [self.F[1], 0])
        br.set_data([self.G[0], 0], [self.G[1], 0])

    def PrintData(self):
        print("A = "+str(self.A[0])+","+str(self.A[1]))
        print("B = "+str(self.B[0])+","+str(self.B[1]))
        print("C = "+str(self.C[0])+","+str(self.C[1]))
        print("D = "+str(self.D[0])+","+str(self.D[1]))
        print("E = "+str(self.E[0])+","+str(self.E[1]))
        print("F = "+str(self.F[0])+","+str(self.F[1]))
        print("G = "+str(self.G[0])+","+str(self.G[1]))
        print("H = "+str(self.H[0])+","+str(self.H[1]))
        print("Body length "+str(self.body_length))
        print("Scope length "+str(self.scope_length))
        print("Scope height "+str(self.scope_height))
        print("Shooting angle"+str(self.shooting_angle))
#Parametric equations for the trajectory of the bullet:
def GetX(t,v,theta,L1):
    x = L1*math.cos(theta)+v*math.cos(theta)*t
    return x
def GetY(t,v,theta,L1,g):
    y = L1*math.sin(theta)+v*math.sin(theta)*t+0.5*g*t**2
    return y
''' Implementation to animate only during the time it flies until hitting the ground at height y = -10
def max_of_two_numbers(num1, num2):#return largest number from 2
    if num1 > num2:
        return num1
    else:
        return num2

def FindFligthTime(R) : #find duration of bullet flight shot from current state of rifle object R
    global v,g
    angle = R.shooting_angle
    flight_time = max_of_two_numbers((-v*math.sin(angle)+math.sqrt((v*math.sin(angle))**2-2*g*(R.body_length*math.sin(angle)+10)))/(2*R.body_length*math.sin(angle)),(-v*math.sin(angle)-math.sqrt((v*math.sin(angle))**2-2*g*(R.body_length*math.sin(angle)+10)))/(2*R.body_length*math.sin(angle)))
    return flight_time
'''

#Rifle geometry parameters:
L1 = 3 #right body length
L2 = 1 #scope length
h = 0.5 #body to scope length
#Bullet motion parameters:
v = 45 #rifle's speed
g = -10 #constant gravitational force
dt = 1/24 #time step size
#Step sizes and other global variables:
duration = 5 #duration of the bullet motion simulation in seconds
dtheta = 0.1 #rotation step size in radians
in_air = False #control variable for bullet state (True if in air False otherwise)
rotating = False #control variable for rifle state (True if rotating False otherwise)
ground = -10 #y coordinate of the ground points (based on rifles coordinate system it is negative)


#Define a sniper rifle object and create the interactive game figure with one axis ("landscape scale" view axes)
MyRifle = Rifle(L1,L2,h,0)
fig,ax = plt.subplots()
ax.axis([-50,50,-50,50]) #x,y range
ax.set_aspect('equal')  #equal scaling
ax.set_title("Landscape view")
bullet, = ax.plot([],[],marker = 'o',color = 'red',markersize = 2)  #bullet line plot
time_register = ax.text(0.05, 0.95, f'Angle : {math.degrees(MyRifle.shooting_angle):.1f}º', transform=ax.transAxes, fontsize=12, verticalalignment='top') #timer and angle counter text box
body, = ax.plot([],[],color = 'brown',linewidth = 2.5)
scope, = ax.plot([],[],color = 'black',linewidth = 2)
left_support, = ax.plot([],[],color = 'black',linewidth = 1)
right_support, = ax.plot([],[],color = 'black',linewidth = 1)
bipod_left, = ax.plot([],[],color = 'black',linewidth = 1)
bipod_right, = ax.plot([],[],color = 'black',linewidth = 1)
laser_line, = ax.plot([MyRifle.B[0] ,10*MyRifle.B[0]],[MyRifle.B[1] ,10*MyRifle.B[1]],color = 'red', linestyle = '--',linewidth = 1)
#second axes creation ... DUE!
# Create an inset axes
inset_ax = fig.add_axes([0.025, 0.5, 0.2, 0.2])
inset_ax.set_title("Close view")
inset_ax.set_xlim(-3.5, 3.5)  # Set the x limits for a closer look around the origin
inset_ax.set_ylim(-3.5, 3.5)  # Set the y limits for a closer look around the origin
#create a target point (center of cirlce)
target_x = 30
target_y = 10
target, = ax.plot([target_x],[target_y],marker = ".",color = "blue",markersize = 15)


# Add the same line plots to the inset axes
inset_bullet, = inset_ax.plot([], [], marker='o', color='red', markersize=2)
inset_body, = inset_ax.plot([], [], color='brown', linewidth=3.5)
inset_scope, = inset_ax.plot([], [], color='black', linewidth=2.5)
inset_left_support, = inset_ax.plot([], [], color='black', linewidth=1)
inset_right_support, = inset_ax.plot([], [], color='black', linewidth=1)
inset_bipod_left, = inset_ax.plot([], [], color='black', linewidth=1.5)
inset_bipod_right, = inset_ax.plot([], [], color='black', linewidth=1.5)
#Draw the rifle in both axes :
MyRifle.DrawRifle(body,scope,left_support,right_support,bipod_left,bipod_right)
MyRifle.DrawRifle(inset_body,inset_scope,inset_left_support,inset_right_support,inset_bipod_left,inset_bipod_right)


#collision detection :
def CheckCollision(t_x,t_y,b_x,b_y): #checks if the target and bullet are close up some to some tolerance epsilon
    distance = math.sqrt((b_x-t_x)**2+(b_y-t_y)**2)
    if distance <= 2.5:
        return True
    return False


#Animation functions
def ShootingAnimation(frame): #shooting animation update function
    global MyRifle,bullet,in_air,duration,target,target_x,target_y
    t = frame*dt #current time based on frame number (between 0 and duration/dt)
    new_x = GetX(t,v,MyRifle.shooting_angle,L1) #compute the new x and y coordinates
    new_y = GetY(t,v,MyRifle.shooting_angle,L1,g)
    bullet.set_data([new_x],[new_y]) #update the data in the bullet plot
    time_register.set_text(f'Time: {t:.1f} s')  # Update time
    if abs(new_y) > 50 or abs(new_x) > 50: #bullet out of the x,y limits so dont animate anymore
        ani.event_source.stop()  # Stop the animation since it hit the target before duration seconds
        time_register.set_text(f'Angle : {math.degrees(MyRifle.shooting_angle):.1f}º')  # Display angle info again
        in_air = False  # update bullet state too
    if CheckCollision(target_x,target_y,new_x,new_y):
        print("HIT!")
        target_x = random.uniform(-50,50)
        target_y= random.uniform(-50,50)
        target.set_data([target_x],[target_y])
        target.set_color((random.random(),random.random(),random.random()))
        ani.event_source.stop()  # Stop the animation since it hit the target before duration seconds
        time_register.set_text(f'Angle : {math.degrees(MyRifle.shooting_angle):.1f}º')  # Display angle info again
        in_air = False #update bullet state too
    if frame == math.ceil(duration/dt): #last frame so update bullet state
        in_air = False
        time_register.set_text(f'Angle : {math.degrees(MyRifle.shooting_angle):.1f}º')  # Display angle info again
    return bullet, time_register #return anything

def on_key_press(event): #key_press event handler
    if isinstance(event, str): #the normal input type for an event handler is of type event but since matplot does not support controller events, I had to manually trigger a keyboard event after detecting a controller button event through pygame
        key = event
    else:
        key = event.key
    global ani,in_air,rotating,bullet,time_register,body,scope,left_support,right_support,bipod_left,bipod_right,MyRifle,duration,laser_line#use this global variables
    if key == 'up' and not in_air and not rotating: #only animate up when no other animation is going on (neither rotation nor bullet shot)
        print("Up")
        rotating = True
        MyRifle.Rotate(dtheta) #rotate it dtheta radians
        #draw on both axes :
        MyRifle.DrawRifle(body,scope,left_support,right_support,bipod_left,bipod_right)
        MyRifle.DrawRifle(inset_body, inset_scope, inset_left_support, inset_right_support, inset_bipod_left,inset_bipod_right)
        laser_line.set_data([MyRifle.B[0] ,10*MyRifle.B[0]],[MyRifle.B[1] ,10*MyRifle.B[1]])
        plt.draw() #make changes appear in screen right after
        time_register.set_text(f'Angle : {math.degrees(MyRifle.shooting_angle):.1f}º')  # Update time text and angle info
        rotating = False
    elif key == 'down' and not in_air and not rotating:
        print("Down")
        rotating = True
        MyRifle.Rotate(-dtheta)  # rotate it -dtheta radians
        #draw on both axes:
        MyRifle.DrawRifle(body,scope,left_support,right_support,bipod_left,bipod_right)
        MyRifle.DrawRifle(inset_body, inset_scope, inset_left_support, inset_right_support, inset_bipod_left,inset_bipod_right)
        laser_line.set_data([MyRifle.B[0] ,10*MyRifle.B[0]],[MyRifle.B[1] ,10*MyRifle.B[1]])
        plt.draw()
        time_register.set_text(f'Angle : {math.degrees(MyRifle.shooting_angle):.1f}º')  # Update time text and angle info
        rotating = False
    elif key == ' ' and not in_air and not rotating:
        in_air = True
        print("Space")
        #duration = FindFligthTime(MyRifle) #find the travelling time until the bullet hits the ground for the animation
        print("Flight time >> "+str(duration))
        ani = FuncAnimation(fig, ShootingAnimation, frames=math.ceil(duration/dt)+1, interval=1000*dt, repeat=False)
        plt.draw()
    elif key == 'escape':
        #close figure
        plt.close()
def on_controller_press(): #controller event handler (it handles the controller_button_press event by triggering a button_event_press on keyboard for matlplotlib )
    pygame.event.pump()  # Update Pygame's internal state
    if joystick.get_button(10):  # R1 button
        fig.canvas.callbacks.process('key_press_event', ' ') #then trigger ' ' key_press_event
    elif joystick.get_button(11):  # Up arrow
        fig.canvas.callbacks.process('key_press_event', 'up') #then trigger 'up' key_press_event
    elif joystick.get_button(12) :  # Down arrow
        fig.canvas.callbacks.process('key_press_event', 'down') #then trigger 'down' key_press_event
    elif joystick.get_button(6):  #Start button
        fig.canvas.callbacks.process('key_press_event', 'escape') #then trigger 'escape' key_press_event

# now, listen to user input and act accordingly:
fig.canvas.mpl_connect('key_press_event', on_key_press) #this connects the key_press_event with the handler on_key_press (KEYBOARD INTERACTION)
pygame.init() #initialize everything first (DUALSHOCK CONTROLLER INTERACTION)
pygame.joystick.init()
joystick = pygame.joystick.Joystick(0) #get the first connnected joystick from Joystick list
joystick.init() #initialize it
# Use a timer to periodically check the joystick's state
timer = fig.canvas.new_timer(interval=0.1)  # every 100ms the timer will call the on_controller_press event handler which will give orders to the on_key_press handler by triggering appropiate key_press_event events
timer.add_callback(on_controller_press)
timer.start()
##################
plt.show() #make all changes visual
