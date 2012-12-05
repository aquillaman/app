from django.db import models


# Create your models here.
class Player(models.Model):
	soc_id 	= models.CharField(max_length=100)
	real 	= models.IntegerField()
	money 	= models.IntegerField()

# class Items(models.Model):
# 	player_id 	= models.ForeignKey(Player)
# 	count 		= models.IntegerField()
# 	typeId 		= models.IntegerField()
