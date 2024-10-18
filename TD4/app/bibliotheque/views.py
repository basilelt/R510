from django.shortcuts import render
from django.http import HttpResponseRedirect
from .forms import LivreForm

from . import  models
# Create your views here.
def ajout(request):
    if request.method == "POST":
        form = LivreForm(request)
        if form.is_valid():
            livre = form.save()
            return HttpResponseRedirect("/bibliotheque/")
        else:
            return render(request,"bibliotheque/ajout.html",{"form": form})
    else :
        form = LivreForm()
        return render(request,"bibliotheque/ajout.html",{"form" : form})

def traitement(request):
    lform = LivreForm(request.POST)
    if lform.is_valid():
        livre = lform.save()
        return HttpResponseRedirect("/bibliotheque/")
    else:
        return render(request,"bibliotheque/ajout.html",{"form": lform})


def index(request):
    liste = list(models.Livre.objects.all())
    return render(request, 'bibliotheque/index.html', {'liste': liste})

def affiche(request, id):
    livre = models.Livre.objects.get(pk=id)
    return render(request,"bibliotheque/affiche.html",{"livre" : livre})

def delete(request, id):
    livre = models.Livre.objects.get(pk=id)
    livre.delete()
    return HttpResponseRedirect("/bibliotheque/")

def update(request, id):
    livre = models.Livre.objects.get(pk=id)
    lform = LivreForm(livre.dico())
    return render(request, "bibliotheque/update.html", {"form": lform,"id":id})

def traitementupdate(request, id):
    lform = LivreForm(request.POST)
    if lform.is_valid():
        livre = lform.save(commit=False)
        livre.id = id;
        livre.save()
        return HttpResponseRedirect("/bibliotheque/")
    else:
        return render(request, "bibliotheque/update.html", {"form": lform, "id": id})
