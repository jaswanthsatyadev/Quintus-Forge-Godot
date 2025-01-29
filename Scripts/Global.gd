extends Node

var playerhp = 100
var rathp = 50

var playerBody: CharacterBody2D
var playerWeaponEquip: bool

var playerDamageAmount = 15
var playerDamageZone: Area2D
var playerAlive: bool
var playerHitBox: Area2D

var EnemyDamageZone: Area2D
var EnemyDamgeAmount: int
