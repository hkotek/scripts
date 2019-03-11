import java.awt.*;import java.awt.event.*;
import java.awt.geom.Ellipse2D;

import javax.swing.*;

import java.io.*;
import java.lang.ref.PhantomReference;
import java.util.*;

public class Beehive extends JFrame implements KeyListener, Runnable
{

	private static final long serialVersionUID = 1L;
	String colors[] = {"b","g","r","y","k"}; // mitcho
	String shapes[] = {"Q","C","T","S"};
	
	static Thread thread = new Thread(new Beehive());
	ArrayList<Question> questions = new ArrayList<Question>();

	boolean firstTime = true;
	JFrame frame;
	int state = 0;int currentQuestion = 0;
	long lastTime = -1;

	Random r = new Random(Calendar.getInstance().getTimeInMillis());
	
	public static void main(String[] args) throws Exception
	{	
		thread.start();
	}
	
	String subjectNumber;
	String age;
	String gender;
	String language;
	
	public void run()
	{
		if(firstTime)
		{
			frame = this;
			frame.setUndecorated(true);frame.setVisible(true);frame.setBackground(Color.black);frame.setExtendedState(Frame.MAXIMIZED_BOTH);
			frame.addWindowListener(new WindowAdapter(){public void windowClosing(WindowEvent e) {System.exit(0);}});
	        frame.addKeyListener(this);
			try {questions = loadFile("input.txt");} catch (Exception e1) {e1.printStackTrace();}

			JPanel panel = new JPanel();
			panel.setLayout(new GridLayout(0,2));
			String[]genders = {"Male","Female"};
			JComboBox genderBox = new JComboBox(genders);
			JTextField subjectNumberField = new JTextField(20);
			JTextField ageField = new JTextField(20);
			String[]languages = {"English","French","Japanese","Mandarin","Russian","Spanish","Other"};
			JComboBox languageBox = new JComboBox(languages);

			panel.add(new JLabel("What is your subject number?"));
			panel.add(subjectNumberField);
			panel.add(new JLabel("What is your age?"));
			panel.add(ageField);
			panel.add(new JLabel("What is your gender?"));
			panel.add(genderBox);
			panel.add(new JLabel("What is your native language?"));
			panel.add(languageBox);
			
			// Populate your panel components here.
			JOptionPane.showMessageDialog(frame,panel,"Subject Information",JOptionPane.QUESTION_MESSAGE);
			subjectNumber = subjectNumberField.getText();
			age = ageField.getText();
			gender = (String)genderBox.getSelectedItem();
			language = (String)languageBox.getSelectedItem();

			firstTime = false;
		}
		
		lastTime = Calendar.getInstance().getTimeInMillis();
		while(true)
		{
			if(currentQuestion < questions.size())
			{
				if(questions.get(currentQuestion).allTime>-1 && state == 1 && (Calendar.getInstance().getTimeInMillis() - lastTime) >= questions.get(currentQuestion).allTime)
				{
					updateTime(state);
					state++;
				}
				repaint();
			}
		}
	}
	
	public void paint(Graphics g)
	{
		if(!firstTime)
		{
			g.drawImage(questions.get(currentQuestion).createImage(frame, state), 0, 0, this);
		}
	}
	
	public void updateTime(int state)
	{
		long temp = Calendar.getInstance().getTimeInMillis();
		questions.get(currentQuestion).updateTime(state, temp - lastTime);
		questions.get(currentQuestion).answerTime = temp - questions.get(currentQuestion).startTime;
		lastTime = temp;
	}
	
	
	public void update(Graphics g) 
	{
		paint(g);
	}
	
	public void keyPressed(KeyEvent e) 
	{
		if(!firstTime && e.getKeyCode() == KeyEvent.VK_SPACE)
		{
			if(state != questions.get(currentQuestion).stateNumber - 1)
			{
				updateTime(state);
				state++;
				if(state == 1)
					questions.get(currentQuestion).startTime = Calendar.getInstance().getTimeInMillis();
			}
		}
	}
	
	public void keyReleased(KeyEvent e) 
	{
		if(e.getKeyCode() == KeyEvent.VK_J || e.getKeyCode() == KeyEvent.VK_F)
		{
			if(state == questions.get(currentQuestion).stateNumber - 1 || questions.get(currentQuestion).allowEarly)
			{
				updateTime(state);
				questions.get(currentQuestion).stateAnswered = state;
				questions.get(currentQuestion).answer = e.getKeyCode() == KeyEvent.VK_J;
				askSecondQuestion();
				state = 0;
				currentQuestion++;
				if(currentQuestion >= questions.size())
					end();
			}
		}
		
	}
	public void askSecondQuestion()
	{
		if(questions.get(currentQuestion).question2.length() > 0)
		{
			questions.get(currentQuestion).answer2 = JOptionPane.showInputDialog(questions.get(currentQuestion).question2);
		}
		frame.requestFocus();
	}
	public void end()
	{
//		The output of the program should be (columns):
//		Particular combination of shapes for that trial (All shapes in Array)
//		Answer_Before
//		Answer_After
//		Number of shapes unveiled
//		Particular combination of shaped unveiled
//		Milliseconds between unveiling and the next press of the space bar
//		Subject Information
//		String subjectNumber;
//		String age;
//		String gender;
//		String language;

		try
		{
			PrintWriter out = new PrintWriter(new FileWriter(new File("output.csv")));
			out.println("BlockNumber, TrialName, ShapeCombinations,UserAnswer 1,TotalStages, PreemptiveAllowed, AnswerStage,CorrectAnswer1, IsCorrect1, TimeToAnswer, UserAnswer2, CorrectAnswer2, IsCorrect2, NumberShapesRevealed, ShapesInStage,TimeSpentOnStage,SubjectNumber, SubjectAge, SubjectGender, SubjectLanguage");
			for(Question question:questions)
			{
				question.outputData(out);
			}
			out.close();
		}
		catch(Exception e1)
		{
			e1.printStackTrace();
		}
		System.exit(0);
	}

	public void keyTyped(KeyEvent e) {}
	
	
	public ArrayList<Question> loadFile(String inputFile) throws Exception
	{
		ArrayList<Question> questions = new ArrayList<Question>();

		ArrayList<ArrayList<Question>> buckets = new ArrayList<ArrayList<Question>>();
		BufferedReader in = new BufferedReader(new FileReader(inputFile));
		while(true)
		{
			Question question = new Question(in);
			
			while(buckets.size()<question.block)
				buckets.add(new ArrayList<Question>());
			buckets.get(question.block - 1).add(question);
			if(in.readLine() == null)
				break;
		}
		for(ArrayList<Question> bucket:buckets)
		{
			int x=bucket.size();
			for(int a=0;a<x;a++)
			{
				Question question = bucket.get((int)(r.nextDouble() * bucket.size()));
				questions.add(question);
				bucket.remove(question);
			}
		}
		
		return questions;
	}

	
    public Shape imageFromString(String s, Graphics2D g,int w,int x,int y)
    {
    	double s3 = Math.sqrt(3)/2;
    	int tx[] = new int[3];tx[0] = (int)(x - w * s3);tx[1] = (int)(x + w * s3);tx[2] = x;
    	int ty[] = new int[3];ty[0] = y - w/2;ty[1] = y - w/2;ty[2] = y+w;
    	
    	double cosP[] = new double[10];double sinP[] = new double[10];
    	for(int c = 0;c<10;c++){cosP[c] = Math.cos(c * Math.PI/5);sinP[c] = Math.sin(c * Math.PI/5);}
    	int sx[] = new int[10];int sy[] = new int[10];
    	for(int c = 0;c<10;c++)
    	{
    		if(c%2 == 0)
    		{
    			sx[c] =(int)( x + w * cosP[c]/2.0);
    			sy[c] =(int)( y + w * sinP[c]/2.0);
    		}
    		else
    		{
    			sx[c] =(int)( x + w * cosP[c]);
    			sy[c] =(int)( y + w * sinP[c]);
    		}
    	}
    	
    	
    	switch(s.charAt(0))
    	{
    	case 'k':g.setColor(Color.black);;break; // mitcho
    	case 'b':g.setColor(Color.blue);break;
    	case 'g':g.setColor(Color.green);break;
    	case 'r':g.setColor(Color.red);;break;
    	case 'y':g.setColor(Color.yellow);;break;
    	}
    	switch(s.charAt(1))
    	{
    	case 'Q':return new Rectangle(x-w,y - w,2*w,2*w);
    	case 'C':return new Ellipse2D.Double(x-w,y - w,2*w,2*w);
    	case 'T':return new Polygon(tx,ty,3);
    	case 'S':return new Polygon(sx,sy,10);
    	}
    	return null;
    }
    
    public Shape hexagon(int w,int x,int y)
    {
    	int sx[] = new int[6];
    	int sy[] = new int[6];
    	double cosP[] = new double[6];double sinP[] = new double[6];
    	for(int c = 0;c<6;c++){cosP[c] = Math.cos(c * Math.PI/3);sinP[c] = Math.sin(c * Math.PI/3);}
    	
    	for(int c = 0;c<6;c++)
    	{
    		sx[c] = (int)(x + w * cosP[c]);
    		sy[c] = (int)(y + w * sinP[c]);
    	}
    	return new Polygon(sx,sy,6);
    }
	
	
	class Question
	{
		public String trialName;
		public int block; 

		public String question1;
		public String question2;

		public int numRows,size;
		boolean all = false;
		int allTime = -1;
		public int[] stateList;
		public int stateNumber;
		public long[] timeSpent;
		public String[] shapeList;
		
		boolean answer;
		boolean correct;
		String answer2;
		String correct2;
		
		long startTime;
		long answerTime;
		
		public int currentState = -1;
		public Image currentImage = null;
		
		boolean allowEarly;
		int stateAnswered;
		
		String message;
		
		public Question(BufferedReader in) throws Exception
		{
			
			trialName = in.readLine();
			block = Integer.parseInt(in.readLine().substring(1));
			
			question1 = in.readLine();
			correct = in.readLine().toUpperCase().equals("YES");
			shapeList = in.readLine().split(",");
			String temp = in.readLine();
			numRows = Integer.parseInt(temp.split(",")[0]);size = Integer.parseInt(temp.split(",")[1]);
			allowEarly = in.readLine().toUpperCase().equals("YES");
			String stateLine = in.readLine();
			if(stateLine.toUpperCase().startsWith("ALL"))
			{
				all = true;
				if(stateLine.endsWith("ms"))
					allTime = Integer.parseInt(stateLine.split(" ")[stateLine.split(" ").length - 1].substring(0,stateLine.split(" ")[stateLine.split(" ").length - 1].length() - 2));
			}
			else
			{
				stateList = new int[stateLine.split(",").length];
				for(int x=0;x<stateLine.split(",").length;x++)
					stateList[x] = Integer.parseInt(stateLine.split(",")[x]);
			}
			question2 = in.readLine();
			correct2 = in.readLine();
			message = in.readLine();
			if(all)
				stateNumber = 3;
			else
				stateNumber = 2 + stateList.length;
			
			timeSpent = new long[stateNumber];
		}
		
		public void outputData(PrintWriter out) throws Exception
		{
//			The output of the program should be (columns):
//				Particular combination of shapes for that trial (All shapes in Array)
//				Answer_Before
//				Answer_After
//				Number of shapes unveiled
//				Particular combination of shaped unveiled
//				Milliseconds between unveiling and the next press of the space bar
//				Subject Information

			if(!all)
			{
				for(int x=0;x<stateList.length;x++)
				{
					out.print(block + ",");
					out.print(trialName + ",");
					for(int y=0;y<shapeList.length-1;y++)
						out.print(shapeList[y] + " ");
					out.print(shapeList[shapeList.length-1] + ",");
					if(answer)
						out.print("Yes,");
					else
						out.print("No,");
					out.print(stateList.length + ",");
					if(allowEarly)
						out.print("Yes,");
					else
						out.print("No,");
					out.print(stateAnswered + ",");
					if(correct)
						out.print("Yes,");
					else
						out.print("No,");
					if(answer == correct)
						out.print("Correct,");
					else
						out.print("Wrong,");
					
					out.print(answerTime + ",");

					if(question2.trim().length() != 0)
					{	
						out.print(answer2 + ",");
						out.print(correct2 + ",");
						if(answer2.trim().equals(correct2.trim()))
							out.print("Correct,");
						else
							out.print("Wrong,");
					}
					else
					{
						out.print(",,,");
					}
					
					if(stateAnswered >= x+1)
						out.print(stateList[x] + ",");
					else
						out.print(0 + ",");
						
					
					int sum = 0;
					for(int y=0;y<x;y++)
						sum+=stateList[y];
					for(int y=0;y<stateList[x];y++)
						out.print(shapeList[sum+y] + " ");
					
					out.print("," + timeSpent[x+1] + ",");
					out.println(subjectNumber + "," + age + "," + gender + "," + language);
				}
			}
			else
			{
				out.print(block + ",");
				out.print(trialName + ",");
				for(int y=0;y<shapeList.length-1;y++)
					out.print(shapeList[y] + " ");
				out.print(shapeList[shapeList.length-1] + ",");

				if(answer)
					out.print("Yes,");
				else
					out.print("No,");
				
				out.print(1 + ",");
				if(allowEarly)
					out.print("Yes,");
				else
					out.print("No,");
				out.print(stateAnswered + ",");

				if(correct)
					out.print("Yes,");
				else
					out.print("No,");
				if(answer == correct)
					out.print("Correct,");
				else
					out.print("Wrong,");
				
				out.print(answerTime + ",");
				
				if(question2.trim().length() != 0)
				{	
					out.print(answer2 + ",");
					out.print(correct2 + ",");
					if(answer2.trim().equals(correct2.trim()))
						out.print("Correct,");
					else
						out.print("Wrong,");
				}
				else
				{
					out.print(",,,");
				}
				

				if(stateAnswered > 0)
					out.print(shapeList.length + ",");
				else
					out.print(0 + ",");
				
				for(int y=0;y<shapeList.length-1;y++)
					out.print(shapeList[y] + " ");
				out.print(shapeList[shapeList.length-1] + ",");
				
				out.print(timeSpent[1] + ",");
//				String subjectNumber;
//				String age;
//				String gender;
//				String language;

				out.println(subjectNumber + "," + age + "," + gender + "," + language);
			}	
		}
		
		public void updateTime(int state,long time)
		{
			timeSpent[state] = time;
		}

		public Image createImage(JFrame frame,int state)
		{
			if(state <= currentState)
				return currentImage;
			currentState = state;
			
			if(all)
			{
				//all
				//0 - question
				//1 - all shown
				//2 - all gray, question shown again
				switch(currentState)
				{
				case 0:currentImage = createIntroImage(frame);break;
				case 1:currentImage = createArrangeImage(frame,0,shapeList.length);drawText(message,(Graphics2D)currentImage.getGraphics());break;
				case 2:currentImage = createEndImage(frame);break;
				}
			}
			else
			{
				if(currentState == 0)
				{
					currentImage = createIntroImage(frame);
				}
				else if(currentState == stateList.length+1)
				{
					currentImage = createEndImage(frame);
				}
				else
				{
					int sum = 0;
					for(int x=0;x<currentState-1;x++)
					{
						sum += stateList[x];
					}
					currentImage = createArrangeImage(frame,sum,sum + stateList[currentState-1]);
					drawText(message,(Graphics2D)currentImage.getGraphics());
				}
			}
			return currentImage;
		}
		
		private Image createIntroImage(JFrame frame)
		{
			Image answer = frame.createImage(frame.getWidth(),frame.getHeight());
			Graphics2D g = (Graphics2D) answer.getGraphics();
			g.drawImage(createArrangeImage(frame,0,0),0,0,frame);
			drawText(question1 + " Press space to continue.",g);
			return answer;
		}
		private Image createEndImage(JFrame frame)
		{
			Image answer = frame.createImage(frame.getWidth(),frame.getHeight());
			Graphics2D g = (Graphics2D) answer.getGraphics();
			g.drawImage(createArrangeImage(frame,shapeList.length,shapeList.length),0,0,frame);
			drawText(question1 + " Press F (yes) or J (no).",g);
			return answer;
		}
		private void drawText(String s,Graphics2D g)
		{
			g.setColor(Color.white);
			g.setFont(new Font("Futura",Font.PLAIN,40));
			g.drawString(s,10,40);
		}

		private Image createArrangeImage(JFrame frame,int numHide,int numShow)
		{
			Image answer = frame.createImage(frame.getWidth(),frame.getHeight());
			Graphics2D g = (Graphics2D) answer.getGraphics();
	    	int numCols = 2 * (int)(shapeList.length/(2 * numRows - 1));
	    	if(shapeList.length%(2 * numRows - 1) >= numRows)
	    		numCols++;
	    	
	    	int wSeg = frame.getWidth()/(numCols+1);
	    	int hSeg = (int)(wSeg * Math.sqrt(3)/2);
	    	
	    	int hSeg2 = frame.getHeight()/(numRows+1);
	    	int wSeg2 = (int)(hSeg2 / (Math.sqrt(3)/2));
	    	
	    	if(hSeg * (numRows+1) > frame.getHeight())
	    	{
	    		wSeg = wSeg2;
	    		hSeg = hSeg2;
	    	}
	    	
	    	for(int x=0;x<shapeList.length;x++)
	    	{
	    		int xC = frame.getWidth()/2 - (numCols * wSeg)/2;
	    		int yC = frame.getHeight()/2;
	    		
	    		if(x % (2 * numRows - 1) < numRows)
	    		{
	    			xC += wSeg * 2 * (int)(x/(2 * numRows - 1));
	    			yC += (2 * (x%(2 * numRows - 1)) - numRows+1) * hSeg;
	    		}
	    		else
	    		{
	    			xC += wSeg * 2 * (int)(x/(2 * numRows - 1)) + wSeg;
	    			yC += (2 * ((x%(2 * numRows - 1))-numRows) - numRows+2) * hSeg;
	    		}

	    		if(x >= numShow)
	    		{
	    			g.setColor(Color.LIGHT_GRAY);
		            g.draw(hexagon(4 * size/3, xC, yC));
	    		}
	    		else if(x >= numHide)
	    		{
	    			g.fill(imageFromString(shapeList[x],g,size,xC,yC));
	    		}
	    		else
	    		{
	    			g.setColor(Color.LIGHT_GRAY);
		            g.fill(hexagon(4 * size/3, xC, yC));
	    		}
	    	}    	
	    	return answer;
		}
		

	}



}