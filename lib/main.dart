import 'package:final_project1/bottom_navigator.dart';
import 'package:final_project1/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'navigation_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      ChangeNotifierProvider(
        create: (context) => NavigationProvider(),
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: BottomNavigatorBar(),
    );
  }
}

class HomePage2 extends StatelessWidget {
  const HomePage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Home', style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
            fontSize: 30,
          )),
        ),
      ),
      body: ListView( // Enables scrolling when content is larger than screen size
        children: [
          Container(
            margin: EdgeInsets.only(top: 30),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true, // Needed to make GridView work inside ListView
              physics: NeverScrollableScrollPhysics(), // Disables scrolling inside GridView
              children: <Widget>[
                _buildImageTile(context, 'Meat and Rice', 'image/meat_and_rice.jpg'),
                _buildImageTile(context, 'Salad', 'image/salad.jpg'),
                _buildImageTile(context, 'Traditional Food', 'image/tradishinal_food.jpg'),
                _buildImageTile(context, 'Sandwishes', 'image/sandwishes.jpg'),
                _buildImageTile(context, 'Grilled Food', 'image/grilled_food.jpg'),
                _buildImageTile(context, 'Sea Food', 'image/seafood.jpg'),
                _buildImageTile(context, 'Steamed Food', 'image/steamed_food.jpg'),
                _buildImageTile(context, 'Animal Products', 'image/animal_product.jpg'),
                _buildImageTile(context, 'Pastries', 'image/pastries.png'),
                _buildImageTile(context, 'Honey', 'image/honey.jpg'),
                _buildImageTile(context, 'Oils', 'image/oil.jpg'),
                _buildImageTile(context, 'all', 'image/all.jpg'),
                // Add more tiles as needed
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, String label, String imagePath) {

    return InkWell(
      onTap: () {
        // Define your action when the image is tapped
        print('$label tapped');
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container( // Optional: Adds a dark overlay to improve text visibility
            margin: EdgeInsets.all(0.5),
            color: Colors.black.withOpacity(0.5),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
