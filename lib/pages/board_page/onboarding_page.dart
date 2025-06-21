import 'package:flutter/material.dart';
import 'package:priem_poliklinika/pages/board_page/first_page_board.dart';
import 'package:priem_poliklinika/pages/board_page/second_page_board.dart';
import 'package:priem_poliklinika/pages/board_page/third_page_board.dart';
import 'package:priem_poliklinika/pages/auth_reg/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => OnboardingPageonBoardingPageState();
}

PageController pageController = PageController();
bool isfirstPage = false;
int currentPage = 0;

class OnboardingPageonBoardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Colors.blueAccent),
        child: Column(
          children: [
            Expanded(
                child: PageView(
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
              },
              controller: pageController,
              children: [
                FirstPageBoard(controller: pageController),
                SecondPageBoard(controller: pageController),
                ThirdPageBoard(controller: pageController),
              ],
            )),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: SmoothPageIndicator(
                count: 3,
                controller: pageController,
                effect: WormEffect(
                  dotHeight: 5,
                  dotWidth: 30,
                  activeDotColor: Colors.white,
                  dotColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: ElevatedButton(
                onPressed: () {
                  if (currentPage == 2) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginIn()));
                  } else {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.8, 50),
                ),
                child: Text(currentPage == 2 ? 'Начать' : 'Далее'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
