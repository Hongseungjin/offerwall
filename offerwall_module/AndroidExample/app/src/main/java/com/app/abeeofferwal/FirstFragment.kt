package com.app.abeeofferwal

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.app.abeeofferwal.databinding.FragmentFirstBinding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragment


/**
 * A simple [Fragment] subclass as the default destination in the navigation.
 */
class FirstFragment : Fragment() {

    private var _binding: FragmentFirstBinding? = null

    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        _binding = FragmentFirstBinding.inflate(inflater, container, false)
        return binding.root

    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.buttonFirst.setOnClickListener {
//            findNavController().navigate(R.id.action_FirstFragment_to_SecondFragment)

            var data: Api.Offerwall = Api.Offerwall()
            data.memId= "abee997"
            data.memGen= "w"
            data.memBirth= "2000-01-01"
            data.memRegion= "인천_서"
            data.firebaseKey= "AAAArCrKtcY:APA91bHDmRlnGIMV9TUWHBgdx_cW59irrr6GssIkX45DUSHiTXcfHV3b0MynCOxwUdm6VTTxhp7lz3dIqAbi0SnoUFnkXlK-0ncZMX-3a3oWV8ywqaEm9A9aGnX-k50SI19hzqOgprRp"
            startActivityForResult(
                MyFlutterActivity
                    .withOfferwall(requireContext(), data),
                0)


//            startActivity(
//                FlutterActivity.createDefaultIntent(requireContext())
//            )
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        // The Flutter activity may cancel the edit. If so, don't update anything.
        if (resultCode == Activity.RESULT_OK) {
            if (data == null) {
                throw RuntimeException("The FlutterBookActivity returning RESULT_OK should always have a return data intent")
            }

            // If the book was edited in Flutter, the Flutter activity finishes and returns an
            // activity result in an intent (the 'data' argument). The intent has an extra which is
            // the edited book in serialized form.
//            val returnedBook = FlutterBookActivity.getBookFromResultIntent(data)
//            // Update our book model list.
//            books[requestCode] = returnedBook
//
//            // Refresh the UI here on the Kotlin side.
//            updateCardWithBook(list.getChildAt(requestCode), returnedBook)
        }
    }
}