// This file is MIT Licensed.

// This is the contract to verity the zk proof of identiy . It is genrated using zokrates.
// To generate a proof follow these steps..

// 1) install zokrates
// 2) cd to circuit folder in this repo
// 3) run zokrates compute-witness -a floolwed by all the inputs (6 given in root.zok file)
// ex) zokrates compute-witness -a 1 1 2 2 3 3 
// This proof will be calculated off chain and three inputs will come from a verified document api
// like digilocker
// This will proof that the user entered original info and cannot fake it.
// If the inputs differ the proof will not be calculated

// 4) run zokrates generate-proof

// proof is a json file.. (proof.json)


pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x0a5f3fa9227e58720c6ac7ec7c1095b2d94ea454d0bc6adc84dcda83f1cb236c), uint256(0x2c1c0ef9f97dbd39ac2bf12b3006c7f3ad18a24407bcc2d731e9c14a7cda9178));
        vk.beta = Pairing.G2Point([uint256(0x02382ef561d2457e69afab6a58c333f5723cd8b9ecabcf60baeb21df1592212a), uint256(0x1ab4542366e1e4d4a51c2a326f8ba1928a1cee50270d2423e70556c5a9c5451f)], [uint256(0x06c19cbd60357ccb1af5ed74c6eeb5afc949fa28561ebfc15fe77462f9a8c5f6), uint256(0x0459ffbb861399bcd34c2e4977209a83101248f94726d413126b3f9d492d865f)]);
        vk.gamma = Pairing.G2Point([uint256(0x0c9ca99f928e0039aabee9cdb80e5cb76b7feb14a3ea35f542482d90188a07a4), uint256(0x06b18c9d8e0814f4f8f94ad4cbc98872df88595c892de6600c7d2eb865102d0e)], [uint256(0x2f6d4874cc73d954289d47c0c8e9931cb6ee38adfcdcfa9794ac3825e4ccae6a), uint256(0x21bc87bf4f40f1935978f43eb1163e81b8653b8535e101a6206228a691aea49d)]);
        vk.delta = Pairing.G2Point([uint256(0x2e08957e6cddf2440860dc456b4a72f120876245e4fbb6117ecf9d7c3ba5f2fe), uint256(0x1a05fb2fe8518182d5c8a635ba3187d6114000b84aebc3b6befb3d2c56b29a0c)], [uint256(0x2d8730ca8dd1341502d2ee87f24c80ff1b810d86c59ecbd3e0d8851a3cdd84c7), uint256(0x1355e57c569c9d43b8263149750ca647c6d71f3c629d90520daca21eda78d7fc)]);
        vk.gamma_abc = new Pairing.G1Point[](4);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x23e0614ca1ce6bb81f6dbf774f43efeec44bd0aae5084efc246018e8b28d29eb), uint256(0x21eaaec1a695b756f17ce5fb97dd5bb81223dec3ebebd64bca53d63cc7a60e0c));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0f77bfcdcc18c7d306715efb9d57dbd53149bdc53f575e9a3f183a8c5bf35478), uint256(0x0c385f3ce652ab079265bfd34400e940e9a95be45e4f49b39ad9925a412ee442));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x02e307f936084a4781b648903d6314adfe4a1f1a1a59d28137ac63d2a87a4f50), uint256(0x114f5098cc957a1410c485dfc2d038738f6b769a9f9b605014328102d8ebaa75));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1a2768f08b4dd1ca8cdb828918e013f354197f82fa466fae362dda5ccb99d5ea), uint256(0x22ccad8ee6743501405699bcc6af58c1edd2a2ac535ad6be512fe80d3dcec3cd));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[3] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](3);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
