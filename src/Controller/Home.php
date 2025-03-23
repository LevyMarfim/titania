<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class Home extends AbstractController
{
    #[Route('/')]
    public function home(): Response
    {
        $gothicNumber = 528;

        return $this->render('main/home.html.twig', [
            'gothNum' => $gothicNumber,
        ]);
    }
}
