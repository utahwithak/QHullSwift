//
//  Vertex.swift
//  QuickHull
//
//  Created by Carl Wieland on 4/20/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation

/**
* Represents vertices of the hull, as well as the points from
* which it is formed.
*
* @author John E. Lloyd, Fall 2004
*/
public final class Vertex {
    /**
    * Spatial point associated with this vertex.
    */
    public var pnt: Vector3

    /**
    * Back index into an array.
    */
    var index = 0

    /**
    * List forward link.
    */
    var prev:Vertex? = nil
    
    /**
    * List backward link.
    */
    var next:Vertex? = nil

    /**
    * Current face that this vertex is outside of.
    */
    var face: Face? = nil
    
    /**
    * Constructs a vertex and sets its coordinates to 0.
    */
    internal init(){
        pnt = Vector3()
    }
    
    /**
    * Constructs a vertex with the specified coordinates
    * and index.
    */
    internal init(x:Double, y:Double, z:Double, idx:Int){
        pnt = Vector3(x: x, y: y, z: z)
        index  = idx
    }
    
}
