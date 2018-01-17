//
//  Vector3d.swift
//  QuickHull
//
//  Created by Carl Wieland on 4/20/15.
/**
 Copyright John E. Lloyd, 2004. All rights reserved. Permission to use,
 copy, modify and redistribute is granted, provided that this copyright
 notice is retained and the author is given credit whenever appropriate.

 This  software is distributed "as is", without any warranty, including
 any implied warranty of merchantability or fitness for a particular
 use. The author assumes no responsibility for, and shall not be liable
 for, any special, indirect, or consequential damages, or any damages
 whatsoever, arising out of or in connection with the use of this
 software.
*/

import Foundation
import SceneKit

public struct Vector3: CustomStringConvertible {
    /**
    * Precision of a double.
    */
    static let DOUBLE_PREC = 2.2204460492503131e-16;

    public var x:Double = 0;

    public var y:Double = 0;

    public var z:Double = 0;
    

    public init()
    {
    }

    public init( v:SCNVector3) {
        self.init(x: v.x, y: v.y, z: v.z)
    }

    public init(x: CGFloat, y: CGFloat, z: CGFloat) {
        self.init(x: Double(x), y: Double(y), z: Double(z))
    }

    public init ( x:Double,  y:Double,  z:Double)
    {
        set (x, y: y, z: z);
    }

    public init( v:Vector3){
	   set(v);
    }

    subscript (index: Int) -> Double {
        get {
            switch index{
            case 0:
                return x
            case 1:
                return y
            case 2:
                return z
            default:
                fatalError("Index out of bounds for vector3")
            }
        }
        set {
            switch index{
            case 0:
                x = newValue
            case 1:
                y = newValue
            case 2:
                z = newValue
            default:
                fatalError("Index out of bounds for vector3")
            }
        }
    }
    
    /**
    * Sets a single element of this vector.
    * Elements 0, 1, and 2 correspond to x, y, and z.
    *
    * @param i element index
    * @param value element value
    * @return element value throws ArrayIndexOutOfBoundsException
    * if i is not in the range 0 to 2.
    */
    mutating func set( _ i:Int,  value:Double){
        switch (i){
        case 0:
            x = value;
        case 1:
            y = value;
        case 2:
            z = value;
        default:
            assert(false, "ERROR OUT OF BOUNDS")
        }
    }
    
    /**
    * Sets the values of this vector to those of v1.
    *
    * @param v1 vector whose values are copied
    */
    mutating func set( _ v1:Vector3)
    {
	   x = v1.x;
	   y = v1.y;
	   z = v1.z;
    }
    
    /**
    * Adds vector v1 to v2 and places the result in this vector.
    *
    * @param v1 left-hand vector
    * @param v2 right-hand vector
    */
    mutating func add (_ v1:Vector3 , v2:Vector3)
    {
	   x = v1.x + v2.x;
	   y = v1.y + v2.y;
	   z = v1.z + v2.z;
    }
    
    /**
    * Adds this vector to v1 and places the result in this vector.
    *
    * @param v1 right-hand vector
    */
    mutating func add (_ v1:Vector3 )
    {
	   x += v1.x;
	   y += v1.y;
	   z += v1.z;
    }
    
    /**
    * Subtracts vector v1 from v2 and places the result in this vector.
    *
    * @param v1 left-hand vector
    * @param v2 right-hand vector
    */
    mutating func sub (_ v1:Vector3 , v2:Vector3)
    {
	   x = v1.x - v2.x;
	   y = v1.y - v2.y;
	   z = v1.z - v2.z;
    }
    
    /**
    * Subtracts v1 from this vector and places the result in this vector.
    *
    * @param v1 right-hand vector
    */
    mutating func sub (_ v1:Vector3 )
    {
	   x -= v1.x;
	   y -= v1.y;
	   z -= v1.z;
    }
    
    /**
    * Scales the elements of this vector by <code>s</code>.
    *
    * @param s scaling factor
    */
    mutating func scale (_ s:Double)
    {
	   x = s*x;
	   y = s*y;
	   z = s*z;
    }
    
    /**
    * Scales the elements of vector v1 by <code>s</code> and places
    * the results in this vector.
    *
    * @param s scaling factor
    * @param v1 vector to be scaled
    */
    mutating func scale (_ s:Double, v1:Vector3 )
    {
	   x = s*v1.x;
	   y = s*v1.y;
	   z = s*v1.z;
    }
    
    /**
    * Returns the 2 norm of this vector. This is the square root of the
    * sum of the squares of the elements.
    *
    * @return vector 2 norm
    */
    func norm()->Double
    {
	   return sqrt(x*x + y*y + z*z);
    }
    
    /**
    * Returns the square of the 2 norm of this vector. This
    * is the sum of the squares of the elements.
    *
    * @return square of the 2 norm
    */
    func normSquared()->Double
    {
	   return x*x + y*y + z*z;
    }
    
    /**
    * Returns the Euclidean distance between this vector and vector v.
    *
    * @return distance between this vector and v
    */
    func distance(_ v:Vector3)->Double
    {
        let dx = x - v.x;
        let dy = y - v.y;
        let dz = z - v.z;
    
        return sqrt(dx*dx + dy*dy + dz*dz);
    }
    
    /**
    * Returns the squared of the Euclidean distance between this vector
    * and vector v.
    *
    * @return squared distance between this vector and v
    */
    func distanceSquared(_ v:Vector3 )->Double
    {
        let dx = x - v.x;
        let dy = y - v.y;
        let dz = z - v.z;
    
	   return (dx * dx + dy * dy + dz * dz);
    }
    
    /**
    * Returns the dot product of this vector and v1.
    *
    * @param v1 right-hand vector
    * @return dot product
    */
    func dot (_ v1:Vector3 )->Double
    {
	   return x*v1.x + y*v1.y + z*v1.z;
    }
    
    /**
    * Normalizes this vector in place.
    */
    mutating func normalize()
    {
        let lenSqr = x*x + y*y + z*z;
        let err = lenSqr - 1;
        if (err > (2*Vector3.DOUBLE_PREC) || err < -(2*Vector3.DOUBLE_PREC))
        {
            let len = sqrt(lenSqr);
            x /= len;
            y /= len;
            z /= len;
        }
    }
    
    /**
    * Sets the elements of this vector to zero.
    */
    mutating func setZero()
    {
	   x = 0;
	   y = 0;
	   z = 0;
    }
    
    /**
    * Sets the elements of this vector to the prescribed values.
    *
    * @param x value for first element
    * @param y value for second element
    * @param z value for third element
    */
    mutating func set (_ x:Double,  y:Double,  z:Double)
    {
	   self.x = x;
	   self.y = y;
	   self.z = z;
    }
    
    /**
    * Computes the cross product of v1 and v2 and places the result
    * in this vector.
    *
    * @param v1 left-hand vector
    * @param v2 right-hand vector
    */
    mutating func cross (_ v1:Vector3 , v2:Vector3)
    {
	   let tmpx = v1.y*v2.z - v1.z*v2.y;
	   let tmpy = v1.z*v2.x - v1.x*v2.z;
	   let tmpz = v1.x*v2.y - v1.y*v2.x;
    
	   x = tmpx;
	   y = tmpy;
	   z = tmpz;
    }

    public var description: String {
    
	   return "\(x) \(y) \(z)"
    }
    
}
