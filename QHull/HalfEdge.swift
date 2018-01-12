//
//  HalfEdge.swift
//  QuickHull
//
//  Created by Carl Wieland on 4/20/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
/*
* Copyright John E. Lloyd, 2003. All rights reserved. Permission
* to use, copy, and modify, without fee, is granted for non-commercial
* and research purposes, provided that this copyright notice appears
* in all copies.
*
* This  software is distributed "as is", without any warranty, including
* any implied warranty of merchantability or fitness for a particular
* use. The authors assume no responsibility for, and shall not be liable
* for, any special, indirect, or consequential damages, or any damages
* whatsoever, arising out of or in connection with the use of this
* software.
*/

import Foundation


final class HalfEdge {
    /**
    * The vertex associated with the head of this half-edge.
    */
    var vertex: Vertex
    
    /**
    * Triangular face associated with this half-edge.
    */
    var face: Face
    
    /**
    * Next half-edge in the triangle.
    */
    var next: HalfEdge?
    
    /**
    * Previous half-edge in the triangle.
    */
    var prev: HalfEdge?
    
    /**
    * Half-edge associated with the opposite triangle
    * adjacent to this edge.
    */
    var opposite: HalfEdge?
    
    /**
    * Constructs a HalfEdge with head vertex <code>v</code> and
    * left-hand triangular face <code>f</code>.
    *
    * @param v head vertex
    * @param f left-hand triangular face
    */
    internal init( v:Vertex, f: Face) {
	   vertex = v
	   face = f
    }

    
    /**
    * Sets the half-edge opposite to this half-edge.
    *
    * @param edge opposite half-edge
    */
    func setOpposite(_ edge: HalfEdge )
    {
	   opposite = edge
	   edge.opposite = self
    }
    
    /**
    * Returns the head vertex associated with this half-edge.
    *
    * @return head vertex
    */
    var head: Vertex {
	   return vertex
    }
    
    /**
    * Returns the tail vertex associated with this half-edge.
    *
    * @return tail vertex
    */
    var tail: Vertex? {
	   return prev?.vertex
    }
    
    /**
    * Returns the opposite triangular face associated with this
    * half-edge.
    *
    * @return opposite triangular face
    */
    var oppositeFace: Face? {
	   return opposite?.face
    }
    
    /**
    * Produces a string identifying this half-edge by the point
    * index values of its tail and head vertices.
    *
    * @return identifying string
    */
    var vertextDescription: String {
        if let tail = tail {
            return "\(tail.index)-\(head.index)"
        }
        else{
            return "?-\(head.index)"
        }
    }
    
    /**
    * Returns the length of this half-edge.
    *
    * @return half-edge length
    */
    var length: Double {
        if let tail = tail {
            return head.pnt.distance(tail.pnt)
        } else{
            return -1
        }
    }
    
    /**
    * Returns the length squared of this half-edge.
    *
    * @return half-edge length squared
    */
    func lengthSquared()->Double
    {
        if let tail = tail {
            return head.pnt.distanceSquared(tail.pnt)
        }  else{
            return -1
        }
    }

}
