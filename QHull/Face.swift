//
//  Face.swift
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

/**
* Basic triangular face used to form the hull.
*
* <p>The information stored for each face consists of a planar
* normal, a planar offset, and a doubly-linked list of three <a
* href=HalfEdge>HalfEdges</a> which surround the face in a
* counter-clockwise direction.
*
* @author John E. Lloyd, Fall 2004 */
open class Face{
    
    static let VISIBLE = 1;
    static let NON_CONVEX = 2;
    static let DELETED = 3;
    
    
    open  var he0:HalfEdge!
    fileprivate var normal = Vector3d() ;
    open  var area:Double = 0;
    fileprivate var centroid = Point3d();
    open  var planeOffset = 0.0;
    
    var index = 0;
    var numVerts = 0;
    
    open var next:Face? = nil;
    
    var mark = Face.VISIBLE;
    
    var outside:Vertex? = nil;
    
    open func computeCentroid (_ centroid:Point3d){
        centroid.setZero();
        var he = he0!;
        repeat
        {
            centroid.add(he.head().pnt);
            he = he.next!;
        }
        while (he !== he0);
        centroid.scale(1.0/Double(numVerts));
    }

    open func computeNormal ( _ normal:Vector3d,  minArea:Double)
    {
        computeNormal(normal);
        
        if (area < minArea)
        {
            // make the normal more robust by removing
            // components parallel to the longest edge
            var hedgeMax:HalfEdge? = nil;
            var lenSqrMax = 0.0
            var hedge = he0;
            repeat
            {
                let lenSqr = hedge!.lengthSquared();
                if (lenSqr > lenSqrMax)
                {
                    hedgeMax = hedge;
                    lenSqrMax = lenSqr;
                }
                hedge = hedge!.next;
            }
            while (hedge !== he0);
            
            let p2 = hedgeMax!.head().pnt;
            let p1 = hedgeMax!.tail()!.pnt;
            let lenMax = sqrt(lenSqrMax);
            let ux = (p2.x - p1.x)/lenMax;
            let uy = (p2.y - p1.y)/lenMax;
            let uz = (p2.z - p1.z)/lenMax;
            let dot = normal.x*ux + normal.y*uy + normal.z*uz;
            normal.x -= dot * ux;
            normal.y -= dot * uy;
            normal.z -= dot * uz;
            
            normal.normalize();         
        }
    }
  
    open func computeNormal ( _ normal:Vector3d)
    {
        var he1 = he0!.next!;
        var he2 = he1.next!;
        
        let p0 = he0!.head().pnt;
        var p2 = he1.head().pnt;
        
        var d2x = p2.x - p0.x;
        var d2y = p2.y - p0.y;
        var d2z = p2.z - p0.z;
        
        normal.setZero();
        
        numVerts = 2;
        
        while (he2 !== he0)
        {
            let d1x = d2x;
            let d1y = d2y;
            let d1z = d2z;
            
            p2 = he2.head().pnt;
            d2x = p2.x - p0.x;
            d2y = p2.y - p0.y;
            d2z = p2.z - p0.z;
            
            normal.x += d1y*d2z - d1z*d2y;
            normal.y += d1z*d2x - d1x*d2z;
            normal.z += d1x*d2y - d1y*d2x;
            
            he1 = he2;
            he2 = he2.next!;
            numVerts += 1;
        }
        area = normal.norm();
        normal.scale (1.0/area);
    }

    func computeNormalAndCentroid(){
        computeNormal (normal);
        computeCentroid (centroid);
        planeOffset = normal.dot(centroid);
        var numv = 0;
        var he = he0!;
        repeat
        {
            numv += 1;
            he = he.next!;
        }
        while (he !== he0);
        assert(numv == numVerts,"face \( getVertexString()) numVerts=\(numVerts) should be \(numv)");
    }
    
    func computeNormalAndCentroid( _ minArea:Double)
    {
        computeNormal(normal, minArea: minArea);
        computeCentroid (centroid);
        planeOffset = normal.dot(centroid);
    }
    
    open static func createTriangle ( _ v0:Vertex, v1:Vertex, v2:Vertex)->Face
    {
	   return createTriangle (v0, v1: v1, v2: v2, minArea: 0);
    }

    /**
    * Constructs a triangule Face from vertices v0, v1, and v2.
    *
    * @param v0 first vertex
    * @param v1 second vertex
    * @param v2 third vertex
    */
    open static func createTriangle (_ v0:Vertex ,  v1:Vertex,  v2:Vertex, minArea:Double)->Face
    {
        let face = Face();
        let he0 = HalfEdge (v: v0, f: face);
        let he1 = HalfEdge (v: v1, f: face);
        let he2 = HalfEdge (v: v2, f: face);
    
        he0.prev = he2;
        he0.next = he1;
        he1.prev = he0;
        he1.next = he2;
        he2.prev = he1;
        he2.next = he0;
    
        face.he0 = he0;
    
        // compute the normal and offset
        face.computeNormalAndCentroid(minArea);
        return face;
    }

    open static func create (_ vtxArray:[Vertex], indices:[Int])->Face
    {
        let face = Face();
        var hePrev:HalfEdge? = nil;
        for i in 0..<indices.count{
            let he = HalfEdge(v: vtxArray[indices[i]], f: face);
            if let prev = hePrev{
                he.prev = prev;
                prev.next = he;
            }
            else{
                face.he0 = he;
            }
            
            hePrev = he;
        }
        face.he0?.prev = hePrev;
        hePrev!.next = face.he0;
    
        // compute the normal and offset
        face.computeNormalAndCentroid();
        return face;
    }



    /**
    * Gets the i-th half-edge associated with the face.
    *
    * @param i the half-edge index, in the range 0-2.
    * @return the half-edge
    */
    open func getEdge(_ iIn:Int)->HalfEdge{
        var i = iIn
        var he = he0;
        while (i > 0){
            he = he?.next!;
            i -= 1;
        }
        while (i < 0){
            he = he?.prev;
            i += 1;
        }
        return he!;
    }

    open func getFirstEdge()->HalfEdge{
        return he0
    }

    /**
    * Finds the half-edge within this face which has
    * tail <code>vt</code> and head <code>vh</code>.
    *
    * @param vt tail point
    * @param vh head point
    * @return the half-edge, or nil if none is found.
    */
    open func findEdge ( _ vt:Vertex,  vh:Vertex)->HalfEdge?{
        var he = he0;
        repeat{
            if (he?.head() === vh && he?.tail() === vt){
                return he;
            }
            he = he?.next;
        }while (he !== he0);
	   return nil;
    }
    
    /**
    * Computes the distance from a point p to the plane of
    * this face.
    *
    * @param p the point
    * @return distance from the point to the plane
    */
    open func distanceToPlane (_ p:Point3d )->Double
    {
	   return normal.x*p.x + normal.y*p.y + normal.z*p.z - planeOffset;
    }

    /**
    * Returns the normal of the plane associated with this face.
    *
    * @return the planar normal
    */
    open func getNormal ()->Vector3d
    {
	   return normal;
    }
    
    open func getCentroid ()->Point3d
    {
	   return centroid;
    }
    
    open func numVertices()->Int
    {
	   return numVerts;
    }

    open func getVertexString ()->String{
        var s:String = "";
        var he = he0;
        repeat{
            if (he === he0){
                s = "\(he?.head().index)";
            }
            else{
                s += " \(he?.head().index)";
            }
            he = he?.next!;
        }while (he !== he0);
	   return s
    }

    open func getVertexIndices (_ idxs:inout [Int]){
        var he = he0;
        var i = 0;
        repeat{
            idxs[i] = (he?.head().index)!;
            i += 1
            he = he?.next!;
        }while (he !== he0);
    }
    func connectHalfEdges (_ hedgePrev:HalfEdge , hedge:HalfEdge)->Face?{
        var discardedFace:Face? = nil;
    
        if (hedgePrev.oppositeFace() === hedge.oppositeFace())
        { // then there is a redundant edge that we can get rid off
    
            let oppFace = hedge.oppositeFace();
            var hedgeOpp:HalfEdge;
    
            if (hedgePrev === he0)
            {
                he0 = hedge;
            }
            if (oppFace!.numVertices() == 3){ // then we can get rid of the opposite face altogether
                hedgeOpp = hedge.opposite!.prev!.opposite!;
    
                oppFace!.mark = Face.DELETED;
                discardedFace = oppFace;
            }
            else{
                hedgeOpp = hedge.opposite!.next!;
    
                if (oppFace!.he0 === hedgeOpp.prev){
                    oppFace!.he0 = hedgeOpp;
                }
                hedgeOpp.prev = hedgeOpp.prev!.prev;
                hedgeOpp.prev!.next = hedgeOpp;
            }
            hedge.prev = hedgePrev.prev;
            hedge.prev!.next = hedge;
    
            hedge.opposite = hedgeOpp;
            hedgeOpp.opposite = hedge;
    
            // oppFace was modified, so need to recompute
            oppFace!.computeNormalAndCentroid();
        }
        else{
            hedgePrev.next = hedge;
            hedge.prev = hedgePrev;
        }
        return discardedFace;
    }

    func checkConsistency(){
        // do a sanity check on the face
        var hedge = he0;
        var maxd = 0.0;
        var numv = 0;
        assert(numVerts >= 0, "degenerate face: \(getVertexString())")
        repeat
        {
            let hedgeOpp = hedge?.opposite;
            assert(hedgeOpp != nil, "face \(getVertexString()): unreflected half edge \(hedge?.getVertexString())")
            assert(hedgeOpp?.opposite === hedge, "face \(getVertexString()): opposite half edge \(hedgeOpp!.getVertexString()) has opposite \(hedgeOpp?.opposite!.getVertexString())");
            assert(hedgeOpp!.head() === hedge?.tail() && hedge?.head() === hedgeOpp!.tail(),"face \(getVertexString()): half edge \(hedge?.getVertexString()) reflected by \(hedgeOpp!.getVertexString())");
            let oppFace = hedgeOpp!.face
//            assert(oppFace != nil , "face \(getVertexString()):no face on half edge \(hedgeOpp!.getVertexString())");
            assert(oppFace.mark != Face.DELETED,"face \(getVertexString()): opposite face \(oppFace.getVertexString()) not on hull")
            
            let d = abs(distanceToPlane((hedge?.head().pnt)!));
            if (d > maxd)
            {
                maxd = d;
            }
            numv += 1;
            hedge = hedge?.next;
        }while (hedge !== he0);
        assert(numv == numVerts,"face \(getVertexString()) numVerts=\(numVerts) should be \(numv)");
    
    }
    
    
//
    open func mergeAdjacentFace ( _ hedgeAdj:HalfEdge,discarded:inout [Face?])->Int
    {
        let oppFace = hedgeAdj.oppositeFace()!;
        var numDiscarded = 0;

        discarded[numDiscarded] = oppFace;
        numDiscarded += 1
        oppFace.mark = Face.DELETED;

        let hedgeOpp = hedgeAdj.opposite;
    
        var hedgeAdjPrev = hedgeAdj.prev!
        var hedgeAdjNext = hedgeAdj.next!
        var hedgeOppPrev = hedgeOpp!.prev!
        var hedgeOppNext = hedgeOpp!.next!
        while (hedgeAdjPrev.oppositeFace() === oppFace){
            hedgeAdjPrev = hedgeAdjPrev.prev!
            hedgeOppNext = hedgeOppNext.next!
        }

        while (hedgeAdjNext.oppositeFace() === oppFace){
            hedgeOppPrev = hedgeOppPrev.prev!
            hedgeAdjNext = hedgeAdjNext.next!
        }
    
        var hedge = hedgeOppNext
        while hedge !== hedgeOppPrev.next {
            hedge.face = self;
            hedge = hedge.next!
        }
    
        if (hedgeAdj === he0){
            he0 = hedgeAdjNext;
        }
	   
        // handle the half edges at the head
        var discardedFace:Face? = nil;
    
        discardedFace = connectHalfEdges (hedgeOppPrev, hedge: hedgeAdjNext);
        if (discardedFace != nil){
            discarded[numDiscarded] = discardedFace!;
            numDiscarded += 1
        }
    
        // handle the half edges at the tail
        discardedFace = connectHalfEdges (hedgeAdjPrev, hedge: hedgeOppNext);
        if (discardedFace != nil)
        {
            discarded[numDiscarded] = discardedFace!;
            numDiscarded += 1
        }
    
	   computeNormalAndCentroid ();
	   checkConsistency();
    
	   return numDiscarded;
    }

    fileprivate func areaSquared (_ hedge0:HalfEdge, hedge1:HalfEdge )->Double
    {
	   // return the squared area of the triangle defined
	   // by the half edge hedge0 and the point at the
	   // head of hedge1.
    
	   let p0 = hedge0.tail()!.pnt;
	   let p1 = hedge0.head().pnt;
	   let p2 = hedge1.head().pnt;
    
	   let dx1 = p1.x - p0.x;
	   let dy1 = p1.y - p0.y;
	   let dz1 = p1.z - p0.z;
    
	   let dx2 = p2.x - p0.x;
	   let dy2 = p2.y - p0.y;
	   let dz2 = p2.z - p0.z;
    
	   let x = dy1*dz2 - dz1*dy2;
	   let y = dz1*dx2 - dx1*dz2;
	   let z = dx1*dy2 - dy1*dx2;
    
	   return x*x + y*y + z*z;
    }
    
    open func triangulate ( _ newFaces:FaceList,  minArea:Double)
    {
        var hedge:HalfEdge? = nil;
        if (numVertices() < 4){
            return;
        }
        let v0 = he0.head();

        hedge = he0.next;
        var oppPrev = hedge!.opposite;
        var face0:Face? = nil;
        hedge = hedge!.next
        while hedge !== he0.prev
        {
            let face = Face.createTriangle (v0, v1: hedge!.prev!.head(), v2: hedge!.head(), minArea: minArea);
            face.he0.next!.setOpposite (oppPrev!);
            face.he0.prev!.setOpposite (hedge!.opposite!);
            oppPrev = face.he0;
            newFaces.add (face);
            if (face0 == nil)
            {
                face0 = face;
            }
            hedge=hedge!.next
        }
        hedge = HalfEdge (v: he0.prev!.prev!.head(), f: self);
        hedge!.setOpposite (oppPrev!);
    
        hedge!.prev = he0;
        hedge!.prev!.next = hedge;
    
        hedge!.next = he0.prev;
        hedge!.next!.prev = hedge;
    
        computeNormalAndCentroid (minArea);
        checkConsistency();

        var face = face0
        while face != nil {
            face!.checkConsistency();
             face = face!.next
        }
    }
}
